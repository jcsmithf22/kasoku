class Space < ApplicationRecord
  include PrettySlug

  belongs_to :owner, class_name: "User"
  has_many :space_memberships
  has_many :members,
           through: :space_memberships,
           source: :user,
           dependent: :destroy

  validates :name, presence: true

  has_many :todos, dependent: :destroy

  def my_role(user_id)
    return "owner" if owner_id == user_id

    space_memberships.find { |sm| sm.user_id == user_id }.role
  end
end
