class ApplicationController < Sinatra::Base
  #include AuthHelpers
  include ApplicationHelpers

  set :views, File.expand_path('../../../views', __FILE__)

  get  '/' do
    @message = session[:tests]
    erb :index, :locals => { :users => User.all, :tests => session[:tests] }
  end
end