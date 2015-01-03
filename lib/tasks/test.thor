require 'pry'

class TestCLI < Thor
  def self.to_s
    'Test'
  end

  default_command :all

  def initialize(*args)
    $LOAD_PATH.unshift 'test'
    super
  end

  desc 'all', 'Run all tests'
  def all
    Dir['test/**/*_test.rb'].map(&File.method(:expand_path)).each(&method(:require))
  end

  desc 'docs', 'Run "Docs" tests'
  def docs
    Dir['test/lib/docs/**/*_test.rb'].map(&File.method(:expand_path)).each(&method(:require))
  end

  desc 'app', 'Run "App" tests'
  def app
    require 'app_test'
  end
end
