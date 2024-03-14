class SessionsController < ApplicationController
  skip_authentication only: %i[new create]

  def new
  end

  def create
    @session =
      User.create_session(
        email: login_params[:email],
        password: login_params[:password]
      )

    if @session
      log_in @session
      flash[:success] = "Successfully logged in"
      redirect_to root_path, status: :see_other
    else
      flash.now[:error] = "Email or password is incorrect"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out

    flash[:success] = "Successfully logged out"
    redirect_to login_path, status: :see_other
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
