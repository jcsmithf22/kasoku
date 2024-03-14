class UsersController < ApplicationController
  skip_authentication only: %i[new create]

  before_action :set_user, only: %i[show edit update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @session = @user.sessions.create
      log_in @session

      flash[:success] = "Welcome to Kasoku, #{@user.name}"
      redirect_to root_path, status: :see_other
    else
      puts @user.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def set_user
    @user = Current.user
  end
end
