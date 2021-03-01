source 'https://rubygems.org'
ruby '~> 2.6.0'

gem 'rake'
gem 'thor'
gem 'pry', '~> 0.12.0'
gem 'activesupport', '~> 5.2', require: false
gem 'yajl-ruby', require: false
gem 'html-pipeline'
gem 'typhoeus'
gem 'nokogiri'
gem 'terminal-table'

group :app do
  gem 'rack'
  gem 'sinatra'
  gem 'sinatra-contrib'
  gem 'rack-ssl-enforcer'
  gem 'thin'
  gem 'sprockets'
  gem 'sprockets-helpers'
  gem 'erubi'
  gem 'browser'
  gem 'sass'
  gem 'coffee-script'
  gem 'chunky_png'
  gem 'sprockets-sass'
  gem 'image_optim'
  gem 'image_optim_pack', platforms: :ruby
end

group :production do
  gem 'uglifier'
  gem 'newrelic_rpm'
end

group :development do
  gem 'better_errors'
end

group :docs do
  gem 'progress_bar', require: false
  gem 'unix_utils', require: false
  gem 'tty-pager', require: false
  gem 'net-sftp', '>= 2.1.3.rc2', require: false
end

group :test do
  gem 'minitest'
  gem 'rr', require: false
  gem 'rack-test', require: false
end

if ENV['SELENIUM'] == '1'
  gem 'capybara'
  gem 'selenium-webdriver'
end
