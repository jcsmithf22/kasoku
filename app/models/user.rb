class User < ApplicationRecord
  include Authentication
  include PrettySlug

  self.slug_prefix = "usr"

  validates :name, presence: true
  validates :email,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            },
            uniqueness: {
              case_insensitive: false
            }

  normalizes :name, with: ->(name) { name.strip }
  normalizes :email, with: ->(email) { email.strip.downcase }
end
