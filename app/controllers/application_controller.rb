class ApplicationController < ActionController::Base
  include Authenticate
  include ApplicationHelper

  helper_method :back_or_default

  before_action :store_last_page

  def store_last_page
    return unless request.get?
    session[:last_page] = session[:current_page]
    session[:current_page] = request.fullpath
    puts "session[:last_page]: #{session[:last_page]}"
    puts "session[:current_page]: #{session[:current_page]}"
  end

  def back_or_default(default_path = root_path)
    session[:last_page] || default_path
  end
end
