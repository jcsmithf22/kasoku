module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    before_action :require_login, unless: :logged_in?

    helper_method :logged_in?
  end

  class_methods do
    def skip_authentication(**options)
      skip_before_action :authenticate, **options
      skip_before_action :require_login, **options
    end

    def allow_unauthenticated(**options)
      skip_before_action :require_login, **options
    end
  end

  protected

  def log_in(session)
    cookies.encrypted.permanent[:session] = { value: session.to_h }
  end

  def log_out
    Current.session&.destroy
  end

  # After logout, Current.user still exists unless authenticate is called again.
  # Make sure any route that uses this method is preceded by a call to authenticate.
  def logged_in?
    Current.user.present?
  end

  private

  def require_login
    flash.now[:notice] = t("login_required")
    render "sessions/new", status: :unauthorized
  end

  # Calls authenticate_using_cookie and authenticate_using_session. If both return nil, Current.app_session and Current.user are set to nil.
  def authenticate
    Current.session = authenticate_using_cookie
    Current.user = Current.session&.user
  end

  # Calls authenticate_using with the cookie data. Returns nil if cookie data is nil.
  def authenticate_using_cookie
    session = cookies.encrypted[:session]
    authenticate_using session&.with_indifferent_access
  end

  # Calls authenticate_using with the session data. Returns nil if session data is nil.
  # def authenticate_using_session
  #   app_session = session[:app_session]
  #   authenticate_using app_session&.with_indifferent_access
  # end

  # Returns nil if data is nil or user is not found or token is invalid.
  def authenticate_using(data)
    data => { user_id:, session_id:, token: }

    user = User.find(user_id)
    user.authenticate_session(app_session, token)
  rescue NoMatchingPatternError, ActiveRecord::RecordNotFound
    nil
  end
end
