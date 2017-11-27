require File.dirname(__FILE__) + '/spec_helper.rb'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.mock_with :rspec
end

describe App do
  let(:app) { App.new }

  context "Home Page /" do
    let(:response) { get "/" }

    it "Should respond: 200" do
      expect(response.status).to eq 200
    end
  end

  context "Listing all heroes /all" do
    let(:response) { get "/all" }

    it "Should respond: 200" do
      expect(response.status).to eq 200
    end
  end

  heroes = ['thrall', 'ana', 'tyreal']
  heroes.each do |hero|
    context "Hero By Name /hero/#{hero}" do
      let(:response) { get "/hero/#{hero}" }

      it "Should respond: 200" do
        expect(response.status).to eq 200
      end

      it "Should contain name [#{hero}]" do
        expect(response.body).to include(hero)
      end
    end
  end

  terms = ['thral', 'ana', 'kehl']
  terms.each do |term|
    context "Search for hero with term /search/#{term}" do
      let(:response) { get "/search/#{term}" }

      it "Should respond: 200" do
        expect(response.status).to eq 200
      end

      it "Should contain search term #{term}" do
        #expect(response.body).to match(%r{#{term}})
      end
    end
  end

  context "Scraping for new heroes /scape" do
    let(:response) { get "/scrape" }

    it "Should respond: 200" do
      expect(response.status).to eq 200
    end
  end

  # context "Admin Sections" do
  #   let(:response) { get "/admin" }

  #   it "Shoud redirect to login" do
  #     expect(response).to redirect_to "/login"
  #   end
  # end
end