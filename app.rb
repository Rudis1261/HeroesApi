# Dependencies
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'httparty'

# Require all the things, models, helpers, controller
Dir.glob('app/{models,helpers,controllers}/*.rb').each {|file| require_relative file }

# Main app
class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true
  set :port, 3000
  set :public_folder, 'public'
  set :show_exceptions, false
  #set :method_override, true # when using post for put / delete etc...
  set :session_secret, 'Super awesome random session string'
  enable :sessions


  # Controllers
  use ApplicationController

  error do
    puts env['sinatra.error'].inspect
    #render_error 500, _('Internal Server Error'), env['sinatra.error'].message
  end

  error Sinatra::NotFound do
    content_type 'text/plain'
    [404, 'Not Found']
  end
end