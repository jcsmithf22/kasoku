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

    has_many :sessions, dependent: :destroy
  end
end
