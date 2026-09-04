module ApplicationHelper
  def owner?(space)
    space.owned_by?(Current.user)
  end

  def back_or_default(default_path = root_path)
    session[:last_page] || default_path
  end
end
