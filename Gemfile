source 'https://rubygems.org'
ruby '3.2.2'

gem 'activesupport', require: false
gem 'html-pipeline'
gem 'nokogiri'
gem 'pry-byebug'
gem 'rake'
gem 'terminal-table'
gem 'thor'
gem 'typhoeus'
gem 'yajl-ruby', require: false

group :app do
  gem 'browser'
  gem 'chunky_png'
  gem 'erubi'
  gem 'image_optim_pack', platforms: :ruby
  gem 'image_optim'
  gem 'rack-ssl-enforcer'
  gem 'rack'
  gem 'rss'
  gem 'sass'
  gem 'sinatra-contrib'
  gem 'sinatra'
  gem 'sprockets-helpers'
  gem 'sprockets-sass'
  gem 'sprockets'
  gem 'thin'
end

group :production do
  gem 'newrelic_rpm'
  gem 'uglifier'
end

group :development do
  gem 'better_errors'
end

group :docs do
  gem 'net-sftp', require: false
  gem 'progress_bar', require: false
  gem 'redcarpet'
  gem 'tty-pager', require: false
  gem 'unix_utils', require: false
end

group :test do
  gem 'minitest'
  gem 'rack-test', require: false
  gem 'rr', require: false
end

if ENV['SELENIUM'] == '1'
  gem 'capybara'
  gem 'selenium-webdriver'
end
