module ApplicationHelpers
  def scrape
    doc = HTTParty.get('http://eu.battle.net/heroes/en/heroes/#')
    heroes = doc.body.scan(/window\.heroes(.+);/)[0]
  end


  # def admin_required
  #   query = {
  #       'redirect' => request.path_info
  #   }.map{|key, value| "#{key}=#{value}"}.join("&")

  #   redirect("/login?#{query}") unless is_admin? && logged_in?
  # end
end