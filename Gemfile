source 'https://rubygems.org'
ruby '4.0.6'

gem 'activesupport', require: false
gem 'html-pipeline', '~> 2.14'
gem 'nokogiri'
gem 'rake'
gem 'terminal-table'
gem 'thor'
gem 'typhoeus'

group :app do
  gem 'chunky_png'
  gem 'erubi'
  gem 'dartsass-sprockets'
  gem 'image_optim_pack', platforms: :ruby
  gem 'image_optim'
  gem 'puma'
  gem 'rack'
  gem 'rss'
  gem 'sinatra'
  gem 'sprockets-helpers'
  gem 'sprockets'
end

group :production do
  gem 'newrelic_rpm'
  gem "terser"
end

group :development do
  gem 'better_errors'
  gem 'pry-byebug'
  gem 'sinatra-contrib'
end

group :docs do
  gem 'redcarpet'
end

group :test do
  gem 'minitest'
  gem 'ostruct'
  gem 'rack-test', require: false
  gem 'rr', require: false
  gem 'simplecov', require: false
end

if ENV['SELENIUM'] == '1'
  gem 'capybara'
  gem 'selenium-webdriver'
end

gem "webrick", "~> 1.9"
