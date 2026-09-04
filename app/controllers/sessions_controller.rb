class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(login_params))
      start_new_session_for user
      flash[:success] = "Successfully logged in"
      redirect_to after_authentication_url, status: :see_other
    else
      flash.now[:error] = "Email or password is incorrect"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session

    flash[:success] = "Successfully logged out"
    redirect_to new_session_path, status: :see_other
  end

  private

  def login_params
    params.expect(user: %i[email password])
  end
end
