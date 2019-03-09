class UpdatesCLI < Thor
  # The GitHub user that is allowed to upload reports
  # TODO: Update this before creating a PR
  UPLOAD_USER = 'jmerle'

  # The repository to create an issue in when uploading the results
  # TODO: Update this before creating a PR
  UPLOAD_REPO = 'jmerle/devdocs'

  def self.to_s
    'Updates'
  end

  def initialize(*args)
    require 'docs'
    require 'progress_bar'
    require 'terminal-table'
    require 'date'
    super
  end

  desc 'check [--github-token] [--upload] [--verbose] [doc]...', 'Check for outdated documentations'
  option :github_token, :type => :string
  option :upload, :type => :boolean
  option :verbose, :type => :boolean
  def check(*names)
    # Convert names to a list of Scraper instances
    # Versions are omitted, if v10 is outdated than v8 is aswell
    docs = names.map {|name| Docs.find(name.split(/@|~/)[0], false)}.uniq

    # Check all documentations for updates when no arguments are given
    docs = Docs.all if docs.empty?

    opts = {
      logger: logger
    }

    if options.key?(:github_token)
      opts[:github_token] = options[:github_token]
    end

    with_progress_bar do |bar|
      bar.max = docs.length
      bar.write
    end

    results = docs.map do |doc|
      result = check_doc(doc, opts)
      with_progress_bar(&:increment!)
      result
    end

    process_results(results)
  rescue Docs::DocNotFound => error
    logger.error(error)
    logger.info('Run "thor docs:list" to see the list of docs.')
  end

  private

  def check_doc(doc, opts)
    # Newer scraper versions always come before older scraper versions
    # Therefore, the first item's release value is the latest scraper version
    #
    # For example, a scraper could scrape 3 versions: 10, 11 and 12
    # doc.versions.first would be the scraper for version 12
    instance = doc.versions.first.new

    scraper_version = instance.class.method_defined?(:options) ? instance.options[:release] : nil
    return error_result(doc, '`options[:release]` does not exist') if scraper_version.nil?

    logger.debug("Checking #{doc.name}")

    instance.get_latest_version(opts) do |latest_version|
      return {
        name: doc.name,
        scraper_version: scraper_version,
        latest_version: latest_version,
        is_outdated: instance.is_outdated(scraper_version, latest_version)
      }
    end
  rescue NotImplementedError
    logger.warn("Couldn't check #{doc.name}, get_latest_version is not implemented")
    error_result(doc, '`get_latest_version` is not implemented')
  rescue
    logger.error("Error while checking #{doc.name}")
    raise
  end

  def error_result(doc, reason)
    {
      name: doc.name,
      error: reason
    }
  end

  def process_results(results)
    successful_results = results.select {|result| result.key?(:is_outdated)}
    failed_results = results.select {|result| result.key?(:error)}

    up_to_date_results = successful_results.select {|result| !result[:is_outdated]}
    outdated_results = successful_results.select {|result| result[:is_outdated]}

    log_results(outdated_results, up_to_date_results, failed_results)
    upload_results(outdated_results, up_to_date_results, failed_results) if options[:upload]
  end

  #
  # Result logging methods
  #

  def log_results(outdated_results, up_to_date_results, failed_results)
    log_failed_results(failed_results) unless failed_results.empty?
    log_successful_results('Up-to-date', up_to_date_results) unless up_to_date_results.empty?
    log_successful_results('Outdated', outdated_results) unless outdated_results.empty?
  end

  def log_successful_results(label, results)
    title = "#{label} documentations (#{results.length})"
    headings = ['Documentation', 'Scraper version', 'Latest version']
    rows = results.map {|result| [result[:name], result[:scraper_version], result[:latest_version]]}

    table = Terminal::Table.new :title => title, :headings => headings, :rows => rows
    puts table
  end

  def log_failed_results(results)
    title = "Documentations that could not be checked (#{results.length})"
    headings = %w(Documentation Reason)
    rows = results.map {|result| [result[:name], result[:error]]}

    table = Terminal::Table.new :title => title, :headings => headings, :rows => rows
    puts table
  end

  #
  # Upload methods
  #

  def upload_results(outdated_results, up_to_date_results, failed_results)
    # We can't create issues without a GitHub token
    unless options.key?(:github_token)
      logger.error('Please specify a GitHub token with the public_repo permission for devdocs-bot with the --github-token parameter')
      return
    end

    logger.info('Uploading the results to a new GitHub issue')

    logger.info('Checking if the GitHub token belongs to the correct user')
    github_get('/user') do |user|
      # Only allow the DevDocs bot to upload reports
      if user['login'] == UPLOAD_USER
        issue = results_to_issue(outdated_results, up_to_date_results, failed_results)

        logger.info('Creating a new GitHub issue')
        github_post("/repos/#{UPLOAD_REPO}/issues", issue) do |created_issue|
          search_params = {
            q: "Documentation versions report in:title author:#{UPLOAD_USER} is:issue repo:#{UPLOAD_REPO}",
            sort: 'created',
            order: 'desc'
          }

          logger.info('Checking if the previous issue is still open')
          github_get('/search/issues', search_params) do |matching_issues|
            previous_issue = matching_issues['items'].find {|item| item['number'] != created_issue['number']}

            if previous_issue.nil?
              logger.info('No previous issue found')
              log_upload_success(created_issue)
            else
              comment = "This report was superseded by ##{created_issue['number']}."

              logger.info('Commenting on the previous issue')
              github_post("/repos/#{UPLOAD_REPO}/issues/#{previous_issue['number']}/comments", {body: comment}) do |_|
                if previous_issue['closed_at'].nil?
                  logger.info('Closing the previous issue')
                  github_patch("/repos/#{UPLOAD_REPO}/issues/#{previous_issue['number']}", {state: 'closed'}) do |_|
                    log_upload_success(created_issue)
                  end
                else
                  logger.info('The previous issue has already been closed')
                  log_upload_success(created_issue)
                end
              end
            end
          end
        end
      else
        logger.error("Only #{UPLOAD_USER} is supposed to upload the results to a new issue. The specified github token is not for #{UPLOAD_USER}.")
      end
    end
  end

  def results_to_issue(outdated_results, up_to_date_results, failed_results)
    results = [
      successful_results_to_markdown('Outdated', outdated_results),
      successful_results_to_markdown('Up-to-date', up_to_date_results),
      failed_results_to_markdown(failed_results)
    ]

    results_str = results.select {|result| !result.nil?}.join("\n\n")

    title = "Documentation versions report for #{Date.today.strftime('%B')} 2019"
    body = <<-MARKDOWN
## What is this?

This is an automatically created issue which contains information about the version status of the documentations available on DevDocs. The results of this report can be used by maintainers when updating outdated documentations.

Maintainers can close this issue when all documentations are up-to-date. This issue is automatically closed when the next report is created.

## Results

The #{outdated_results.length + up_to_date_results.length + failed_results.length} documentations are divided as follows:
- #{outdated_results.length} that #{outdated_results.length == 1 ? 'is' : 'are'} outdated
- #{up_to_date_results.length} that #{up_to_date_results.length == 1 ? 'is' : 'are'} up-to-date (patch updates are ignored)
- #{failed_results.length} that could not be checked
    MARKDOWN

    {
      title: title,
      body: body.strip + "\n\n" + results_str
    }
  end

  def successful_results_to_markdown(label, results)
    return nil if results.empty?

    title = "#{label} documentations (#{results.length})"
    headings = ['Documentation', 'Scraper version', 'Latest version']
    rows = results.map {|result| [result[:name], result[:scraper_version], result[:latest_version]]}

    results_to_markdown(title, headings, rows)
  end

  def failed_results_to_markdown(results)
    return nil if results.empty?

    title = "Documentations that could not be checked (#{results.length})"
    headings = %w(Documentation Reason)
    rows = results.map {|result| [result[:name], result[:error]]}

    results_to_markdown(title, headings, rows)
  end

  def results_to_markdown(title, headings, rows)
    "<details>\n<summary>#{title}</summary>\n\n#{create_markdown_table(headings, rows)}\n</details>"
  end

  def create_markdown_table(headings, rows)
    header = headings.join(' | ')
    separator = '-|' * headings.length
    body = rows.map {|row| row.join(' | ')}

    header + "\n" + separator[0...-1] + "\n" + body.join("\n")
  end

  def log_upload_success(created_issue)
    logger.info("Successfully uploaded the results to #{created_issue['html_url']}")
  end

  #
  # HTTP utilities
  #

  def github_get(endpoint, params = {}, &block)
    github_request(endpoint, {method: :get, params: params}, &block)
  end

  def github_post(endpoint, params, &block)
    github_request(endpoint, {method: :post, body: params.to_json}, &block)
  end

  def github_patch(endpoint, params, &block)
    github_request(endpoint, {method: :patch, body: params.to_json}, &block)
  end

  def github_request(endpoint, opts, &block)
    url = "https://api.github.com#{endpoint}"

    # GitHub token authentication
    opts[:headers] = {
      Authorization: "token #{options[:github_token]}"
    }

    # GitHub requires the Content-Type to be application/json when a body is passed
    if opts.key?(:body)
      opts[:headers]['Content-Type'] = 'application/json'
    end

    logger.debug("Making a #{opts[:method]} request to #{url}")

    Docs::Request.run(url, opts) do |response|
      # response.success? is false if the response code is 201
      # GitHub returns 201 Created after an issue is created
      if response.success? || response.code == 201
        block.call JSON.parse(response.body)
      else
        logger.error("Couldn't make a #{opts[:method]} request to #{url} (response code #{response.code})")
        block.call nil
      end
    end
  end

  # A utility method which ensures no progress bar is shown when stdout is not a tty
  def with_progress_bar(&block)
    return unless $stdout.tty?
    @progress_bar ||= ::ProgressBar.new
    block.call @progress_bar
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger.formatter = proc {|severity, datetime, progname, msg| "[#{severity}] #{msg}\n"}
    end
  end
end
