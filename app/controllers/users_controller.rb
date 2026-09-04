class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def show
  end

  def edit
  end

  def update
  end

  private

  def set_user
    @user = Current.user
  end
end
