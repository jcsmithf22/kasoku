class UserMailer < ApplicationMailer
  def email_confirmation
    @token = params[:user].generate_token_for(:email_confirmation)
    mail to: params[:user].unconfirmed_email
  end
end
