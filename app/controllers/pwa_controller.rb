class PwaController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  def service_worker
  end

  def manifest
  end
end
