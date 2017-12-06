module ScraperHelper

  def error(message = false)
    {
      :error => true,
      :message => message ||= 'Unable to process your request'
    }.to_json
  end


  def scrape_heroes
    cached = self.read_from_disk
    if !cached.nil?
      return cached
    end

    puts "Scraping from site"

    doc = HTTParty.get(ApplicationController.base_url)
    data = doc.body.scan(/window\.heroes.+= (.+);/)

    # Fall back should a request fail, try and force read locally
    if (data.nil? || data[0].nil? || data[0].first.nil?)
      puts "Failed to scrape, falling back to local cached file"
      return self.read_from_disk true
    end

    heroes = JSON.parse(data[0].first).to_json
    if !heroes.nil?
      self.save_to_disk(heroes)
      return self.parse_json_data(heroes)
    else
      return self.error 'Unabled to scrape'
    end
  end


  def scrape_hero(name)
    return if name.nil?

    doc = HTTParty.get(ApplicationController.hero_base_url % name)
    data = doc.body.scan(/window\.hero.+= (.+);/)

    # Fall back should a request fail, try and force read locally
    # if (data.nil? || data[0].nil? || data[0].first.nil?)
    #   puts "Failed to scrape, falling back to local cached file"
    #   return self.read_from_disk true
    # end

    hero = JSON.parse(data[0].first)
    if !hero.nil?
      #self.save_hero_to_disk(hero)
      return self.parse_hero_json_data(hero).to_json
    else
      return self.error 'Unabled to scrape hero data'
    end
  end


  def read_from_disk(force = false)
    return nil if !File.exists?(ApplicationController.local_file)
    return nil if !force && ((Time.now - File.mtime(ApplicationController.local_file)).to_i / ApplicationController.local_file_cache_time) > 1

    puts "Reading feed from cache"

    File.read(ApplicationController.local_file)
  end

  def read_hero_from_disk(name, force = false)
    return if name.nil?
    return nil if !File.exists?(ApplicationController.hero_local_file % name)
    return nil if !force && ((Time.now - File.mtime(ApplicationController.hero_local_file % name)).to_i / ApplicationController.local_file_cache_time) > 1

    puts "Reading hero feed from cache"

    File.read(ApplicationController.hero_local_file % name)
  end


  def parse_json_data(data)
    #return data
    data = JSON.parse(data).map do |hero|
      parse_hero_json_data hero
    end

    return data.to_json
  end

  def parse_hero_json_data(hero)

    @data = {}
    @keys = {
        'heroics' => 'heroicAbilities',
        'abilities' => 'abilities'
    }

    @data['trait'] = @values = {
        'name' => '',
        'description' => '',
        'slug' => '',
        'image' => ''
    }

    @stats = {
        'damage' => hero['stats']['damage'] ||= 0,
        'utility' => hero['stats']['utility'] ||= 0,
        'survivability' => hero['stats']['survivability'] ||= 0,
        'complexity' => hero['stats']['complexity'] ||= 0
    }

    @keys.each_key  do |key|
      needle = @keys[key]
      if !hero[needle].nil?
        @data[key] = hero[needle].map do |item|
            {
                'name' => item['name'],
                'description' => item['description'],
                'slug' => item['slug'],
                'image' => ApplicationController.image_urls['trait'] % [hero['slug'], item['slug']]
            }
          end
      else
        @data[key] = @values
      end
    end

    if !hero['trait'].nil?
      @data['trait'] = {
          'name' => hero['trait']['name'],
          'description' => hero['trait']['name'],
          'slug' => hero['trait']['slug'],
          'image' => ApplicationController.image_urls['trait'] % [hero['slug'], hero['trait']['slug']]
      }
    end

    {
      'name' => hero['name'],
      'slug' => hero['slug'],
      'title' => hero['title'],
      'description' => hero['role']['description'],
      'role' => hero['role']['name'],
      'type' => hero['type']['name'],
      'franchise' => hero['franchise'],
      'difficulty' => hero['difficulty'],
      'live' => hero['revealed'],
      'poster_image' => ApplicationController.image_urls['bust'] % hero['slug'],
      'stats' => @stats,
      'trait' => @data['trait'],
      'abilities' => @data['abilities'],
      'heroics' => @data['heroics'],
      #'original' => hero
    }
  end


  def save_to_disk(data)
    data = self.parse_json_data(data)
    File.open(ApplicationController.local_file, 'w') { |file| file.write(data) }
  end

  def save_hero_to_disk(name, data)
    return nil if name.nil?
    data = self.parse_hero_json_data(data)
    File.open(ApplicationController.hero_local_file % name, 'w') { |file| file.write(data) }
  end


  def find_hero_by_name(name)
    name = name.to_s.downcase
    heroes = self.scrape_heroes
    return self.error if heroes.nil?

    find = JSON.parse(heroes).select do |h|
      h['name'].downcase.include?(name)
    end

    return self.error if find.nil? || find.first.nil?
    return find.first.to_json
  end


  def find_hero_by_term(term)
    term = term.to_s.downcase
    heroes = self.scrape_heroes
    return self.error if heroes.nil?

    find = JSON.parse(heroes).select do |h|
      h['name'].downcase.include?(term) ||
      h['title'].downcase.include?(term) ||
      h['franchise'].downcase.include?(term) ||
      h['role'].downcase.include?(term)
    end

    return self.error if find.nil?
    find.to_json
  end
end