require 'bundler/setup'

$LOAD_PATH.unshift 'lib'

require 'app'

map '/' do
  run App
end

if App.development?
  map '/assets' do
    run App.sprockets
  end
end
