module ApplicationHelpers
  # def login_required
  #   query = {
  #       'redirect' => request.path_info
  #   }.map{|key, value| "#{key}=#{value}"}.join("&")

  #   redirect("/login?#{query}") unless logged_in?
  # end


  # def admin_required
  #   query = {
  #       'redirect' => request.path_info
  #   }.map{|key, value| "#{key}=#{value}"}.join("&")

  #   redirect("/login?#{query}") unless is_admin? && logged_in?
  # end
end