#!/usr/bin/env rake

require 'bundler/setup'
require 'thor'

$LOAD_PATH.unshift 'lib'

namespace :assets do
  desc 'Compile all assets'
  task :precompile do
    load 'tasks/assets.thor'
    AssetsCLI.new.compile
  end
end
