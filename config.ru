require './app'
run Sinatra::Application

require 'sinatra'

set :database_file, "#{APP_ROOT}/config/database.yml"
require 'sinatra/activerecord/rake'

env = ENV["RACK_ENV"]

YAML::load(File.open('config/database.yml'))[env].symbolize_keys.each do |key, value|
  set key, value
end

ActiveRecord::Base.establish_connection(
  			adapter: "mysql", 
  			host: settings.host,
  			database: settings.spaza_shop,
  			username: settings.username,
  			password: settings.password)