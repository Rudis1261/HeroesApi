# Dependencies
require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'
require 'httparty'

# Require all the things, models, helpers, controller
Dir.glob('app/{models,helpers,controllers}/*.rb').each {|file| require_relative file }

# Main app
class App < Sinatra::Base

  # Controllers
  use ApplicationController

  configure(:production){  p "Running in Production mode" }
  configure(:development){ p "Running in Development mode" }

  configure do
    set :root, File.dirname(__FILE__)
    set :static, true
    set :port, 3000
    set :public_folder, 'public'
    set :show_exceptions, false
    set :session_secret, 'Super awesome random session string'
    enable :sessions

    # Some application settings, probably doing this wrong, but the controller extends from Sinatra,
    # so I am not able to access the settings
    ApplicationController.base_url = 'http://eu.battle.net/heroes/en/heroes/'
    ApplicationController.hero_base_url = 'http://eu.battle.net/heroes/en/heroes/%s/'
    ApplicationController.local_file = File.dirname(__FILE__) + '/data/heroes.json'
    ApplicationController.hero_local_file = File.dirname(__FILE__) + '/data/heroes/%s'
    ApplicationController.local_file_cache_time = 10
  end

  configure :production do
    ApplicationController.local_file_cache_time = 86400.0
  end

  error do
    puts env['sinatra.error'].inspect
    #render_error 500, _('Internal Server Error'), env['sinatra.error'].message
  end

  error Sinatra::NotFound do
    content_type 'text/plain'
    [404, 'Not Found']
  end
end