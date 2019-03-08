class UpdatesCLI < Thor
  def self.to_s
    'Updates'
  end

  def initialize(*args)
    require 'docs'
    require 'progress_bar'
    super
  end

  desc 'check [doc]...', 'Check for outdated documentations'
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

    outdated = results.select {|result| result.is_a?(Hash) && result[:is_outdated]}
    return if outdated.empty?

    logger.info("Outdated documentations (#{outdated.length}):")
    outdated.each do |result|
      logger.info("#{result[:name]}: #{result[:current_version]} -> #{result[:latest_version]}")
    end
  rescue Docs::DocNotFound => error
    logger.error(error)
    logger.info('Run "thor docs:list" to see the list of docs.')
  end

  private

  def check_doc(doc)
    # Scraper versions are always sorted from new to old
    # Therefore, the first item's release value is the latest current scraper version
    #
    # For example, a scraper could scrape 3 versions: 10, 11 and 12
    # doc.versions.first would be the scraper for version 12 if the scraper is written like all the other scrapers are
    instance = doc.versions.first.new

    current_version = instance.options[:release]
    return nil if current_version.nil?

    latest_version = instance.get_latest_version
    return nil if latest_version.nil?

    {
      name: doc.name,
      current_version: current_version,
      latest_version: latest_version,
      is_outdated: instance.is_outdated(current_version, latest_version)
    }
  rescue NotImplementedError
    logger.warn("Can't check #{doc.name}, get_latest_version is not implemented")
  rescue => error
    logger.error("Error while checking #{doc.name}: #{error}")
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.formatter = proc do |severity, datetime, progname, msg|
        prefix = severity != "INFO" ? "[#{severity}] " : ""
        "#{prefix}#{msg}\n"
      end
    end
  end
end
