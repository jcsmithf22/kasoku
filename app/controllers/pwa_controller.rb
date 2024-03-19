class PwaController < ApplicationController
  skip_authentication
  skip_forgery_protection

  def service_worker
  end

  def manifest
  end
end
