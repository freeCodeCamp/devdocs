require 'pry'

class TestCLI < Thor
  def self.to_s
    'Test'
  end

  default_command :all

  desc 'all', 'Run all tests'
  def all
    $LOAD_PATH.unshift 'test'
    Dir['test/**/*_test.rb'].map(&File.method(:expand_path)).each(&method(:require))
  end
end
