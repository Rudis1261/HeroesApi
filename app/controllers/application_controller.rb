class ApplicationController < Sinatra::Base
  #include AuthHelpers
  #include ApplicationHelpers
  include ScraperHelper

  def self.base_url=(url); @base_url = url; end
  def self.base_url; @base_url; end

  def self.local_file=(fileName); @local_file = fileName; end
  def self.local_file; @local_file; end

  def self.local_file_cache_time=(miliseconds); @local_file_cache_time = miliseconds; end
  def self.local_file_cache_time; @local_file_cache_time; end

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

  ['/all', '/scrape'].each do |route|
    get "#{route}" do
      return scrape_heroes
    end
  end

  ['/hero/:name', '/name/:name'].each do |route|
    get "#{route}" do
      return find_hero_by_name(params[:name])
    end
  end

  ['/search/:term', '/find/:term'].each do |route|
    get "#{route}" do
      return find_hero_by_term(params[:term])
    end
  end
end