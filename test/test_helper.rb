ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
Bundler.require :test

$LOAD_PATH.unshift 'lib'

require 'minitest/autorun'
require 'minitest/pride'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/testing/assertions'
require 'rr'

Dir[File.dirname(__FILE__) + '/support/*.rb'].each do |file|
  autoload File.basename(file, '.rb').camelize, file
end

ActiveSupport::TestCase.test_order = :random

class MiniTest::Spec
  include ActiveSupport::Testing::Assertions

  module DSL
    def context(*args, &block)
      describe(*args, &block)
    end
  end
end

def tmp_path
  $tmp_path ||= mk_tmp
end

def mk_tmp
  File.expand_path('../tmp', __FILE__).tap do |path|
    FileUtils.mkdir(path)
  end
end

def rm_tmp
  FileUtils.rm_rf $tmp_path if $tmp_path
end

Minitest.after_run do
  rm_tmp
end
