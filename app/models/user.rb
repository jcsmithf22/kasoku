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

  has_many :space_memberships
  has_many :spaces, through: :space_memberships
  has_many :owned_spaces, class_name: "Space", foreign_key: :owner_id

  def is_owner_of?(owner)
    owner == self
  end
end
