class Space < ApplicationRecord
  include PrettySlug

  belongs_to :owner, class_name: "User"
  has_many :space_memberships
  has_many :members, through: :space_memberships, source: :user

  validates :name, presence: true

  def my_role(user_id)
    return "owner" if owner_id == user_id

    space_memberships.find { |sm| sm.user_id == user_id }.role
  end
end
