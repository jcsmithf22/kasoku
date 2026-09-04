class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :space_memberships, dependent: :destroy
  has_many :spaces, through: :space_memberships
  has_many :owned_spaces, class_name: "Space", foreign_key: :owner_id, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, presence: true

  generates_token_for :email_confirmation, expires_in: 7.days do
    unconfirmed_email
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def confirm_email
    update(email_address: unconfirmed_email, unconfirmed_email: nil)
  end
end
