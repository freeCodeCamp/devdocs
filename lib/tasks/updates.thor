class UpdatesCLI < Thor
  def self.to_s
    'Updates'
  end

  def initialize(*args)
    require 'docs'
    require 'progress_bar'
    super
  end

  desc 'check [--verbose] [doc]...', 'Check for outdated documentations'
  option :verbose, :type => :boolean
  def check(*names)
    # Convert names to a list of Scraper instances
    # Versions are omitted, if v10 is outdated than v8 is aswell
    docs = names.map {|name| Docs.find(name.split(/@|~/)[0], false)}.uniq

    # Check all documentations for updates when no arguments are given
    docs = Docs.all if docs.empty?

    progress_bar = ::ProgressBar.new docs.length
    progress_bar.write

    results = docs.map do |doc|
      result = check_doc(doc)
      progress_bar.increment!
      result
    end

    valid_results = results.select {|result| result.is_a?(Hash)}

    up_to_date_results = valid_results.select {|result| !result[:is_outdated]}
    outdated_results = valid_results.select {|result| result[:is_outdated]}

    log_results('Up-to-date', up_to_date_results) if options[:verbose] and !up_to_date_results.empty?
    logger.info("") if options[:verbose] and !up_to_date_results.empty? and !outdated_results.empty?
    log_results('Outdated', outdated_results) unless outdated_results.empty?
  rescue Docs::DocNotFound => error
    logger.error(error)
    logger.info('Run "thor docs:list" to see the list of docs.')
  end

  private

  def check_doc(doc)
    # Newer scraper versions always come before older scraper versions
    # Therefore, the first item's release value is the latest current scraper version
    #
    # For example, a scraper could scrape 3 versions: 10, 11 and 12
    # doc.versions.first would be the scraper for version 12
    instance = doc.versions.first.new

    return nil unless instance.class.method_defined?(:options)

    current_version = instance.options[:release]
    return nil if current_version.nil?

    logger.debug("Checking #{doc.name}")

    instance.get_latest_version do |latest_version|
      return {
        name: doc.name,
        current_version: current_version,
        latest_version: latest_version,
        is_outdated: instance.is_outdated(current_version, latest_version)
      }
    end

    return nil
  rescue NotImplementedError
    logger.warn("Couldn't check #{doc.name}, get_latest_version is not implemented")
  rescue
    logger.error("Error while checking #{doc.name}")
    raise
  end

  def log_results(label, results)
    logger.info("#{label} documentations (#{results.length}):")

    results.each do |result|
      logger.info("#{result[:name]}: #{result[:current_version]} -> #{result[:latest_version]}")
    end
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger.formatter = proc do |severity, datetime, progname, msg|
        prefix = severity != "INFO" ? "[#{severity}] " : ""
        "#{prefix}#{msg}\n"
      end
    end
  end
end
