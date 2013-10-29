source 'https://rubygems.org'
ruby '2.0.0'

gem 'thor'
gem 'pry', '~> 0.9.12'
gem 'activesupport', '~> 4.0', require: false
gem 'yajl-ruby', require: false
gem 'therubyracer'

group :app do
  gem 'rack'
  gem 'sinatra'
  gem 'sinatra-contrib'
  gem 'thin'
  gem 'sprockets'
  gem 'sprockets-helpers'
  gem 'erubis'
  gem 'browser'
  gem 'sass'
  gem 'coffee-script'
end

group :production do
  gem 'uglifier'
end

group :development do
  gem 'better_errors'
end

group :docs do
  gem 'typhoeus'
  gem 'nokogiri', '~> 1.6.0'
  gem 'html-pipeline'
  gem 'progress_bar'
  gem 'unix_utils'
end

group :test do
  gem 'minitest'
  gem 'rr', require: false
end
