# Dependencies
require 'sinatra'
require 'sinatra/activerecord'
require 'sprockets'
require 'sprockets-helpers'
require 'uglifier'
require 'sass'

# Require all the things, models, helpers, controller
Dir.glob('app/{models,helpers,controllers}/*.rb').each {|file| require_relative file }

# Main app
class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :sprockets, Sprockets::Environment.new(root)
  set :assets_prefix, '/assets'
  set :digest_assets, false
  set :static, true
  set :port, 3000
  set :public_folder, 'public'
  set :views, 'views'
  set :show_exceptions, false
  #set :method_override, true # when using post for put / delete etc...
  set :session_secret, 'Super awesome random session string'
  enable :sessions

  # Setup Sprockets
  configure do
    sprockets.append_path File.join(root, 'assets', 'stylesheets')
    sprockets.append_path File.join(root, 'assets', 'javascripts')
    sprockets.append_path File.join(root, 'assets', 'images')

    # Configure Sprockets::Helpers (if necessary)
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.digest      = digest_assets
      config.public_path = public_folder

      # Force to debug mode in development mode
      # Debug mode automatically sets
      # expand = true, digest = false, manifest = false
      config.debug       = true if development?
    end
  end

  # compress assets
  sprockets.js_compressor  = :uglify
  sprockets.css_compressor = :scss

  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.sprockets.call(env)
  end

  # Controllers
  use ApplicationController
  use AccountController
  use AdminController

  error do
    puts env['sinatra.error'].inspect
    #render_error 500, _('Internal Server Error'), env['sinatra.error'].message
  end

  error Sinatra::NotFound do
    content_type 'text/plain'
    [404, 'Not Found']
  end
end