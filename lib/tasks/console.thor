require 'pry'

class ConsoleCLI < Thor
  def self.to_s
    'Console'
  end

  def initialize(*args)
    trap('INT') { puts; exit } # exit on ^C
    super
  end

  default_command :default

  desc '', 'Start a REPL'
  def default
    Pry.start
  end

  desc 'docs', 'Start a REPL in the "Docs" module'
  def docs
    require 'docs'
    Docs.pry
  end
end

Pry::Commands.create_command 'test' do
  description 'Run tests in the "test" directory'
  group 'Testing'

  banner <<-BANNER
    Usage: test [<path>]

    If <path> is a file, run it ("_test.rb" suffix is optional).
    If <path> is a directory, run all test files inside it.
    Default to all test files.
  BANNER

  def process
    if pattern = args.first
      pattern.prepend 'test/'

      if File.directory?(pattern)
        pattern << '/**/*_test.rb'
      elsif File.extname(pattern).empty?
        pattern << '*_test.rb'
      end
    else
      pattern = 'test/**/*_test.rb'
    end

    paths = Dir.glob(pattern).map(&File.method(:expand_path))

    if paths.empty?
      output.puts 'No test files found.'
      return
    end

    pid = fork do
      begin
        $LOAD_PATH.unshift 'test'
        paths.each(&method(:require))
      rescue Exception => e
        _pry_.last_exception = e
        run 'wtf?'
        exit!
      end
    end

    Process.wait(pid)
  end
end
