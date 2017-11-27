class ApplicationController < Sinatra::Base
  #include AuthHelpers
  include ApplicationHelpers

  set :views, File.expand_path('../../../views', __FILE__)

  before do
    content_type :text
  end

  get  '/' do
    data = {
        '/' => 'Home',
        '/all' => 'All heroes',
        '/hero/<name>' => 'A specific hero by slug',
        '/search/<term>' => 'Find a hero by name',
        '/scrape' => 'Scrape to update the heroes'
    }
    return JSON.pretty_generate(data)
  end


  get '/all' do
    data = {}
    return JSON.pretty_generate(data)
  end


  get '/hero/:name' do
    data = {
        'name': params[:name] ||= 'No name provided'
    }
    return JSON.pretty_generate(data)
  end


  get '/search/:term' do
    data = {
        'term': params[:term] ||= 'No search term provided'
    }
    return JSON.pretty_generate(data)
  end

  get '/scrape' do
    #return JSON.pretty_generate scrape
    return scrape
  end
end