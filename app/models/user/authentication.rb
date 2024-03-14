module User::Authentication
  extend ActiveSupport::Concern

  included do
    has_secure_password
    validates :password,
              on: %i[create password_change],
              presence: true,
              length: {
                minimum: 8
              }

    has_many :sessions
  end

  class_methods do
    def create_session(email:, password:)
      user = User.authenticate_by(email: email, password: password)
      user.sessions.create if user.present?
    end
  end

  def authenticate_session(session_id, token)
    sessions.find(session_id).authenticate_token(token)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
