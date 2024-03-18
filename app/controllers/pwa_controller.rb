class PwaController < ApplicationController
  skip_before_action :store_last_page, only: :new
  skip_authentication
  skip_forgery_protection

  def service_worker
  end

  def manifest
  end
end
