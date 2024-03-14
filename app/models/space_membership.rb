class SpaceMembership < ApplicationRecord
  belongs_to :user
  belongs_to :space

  scope :admin, -> { where(role: "admin") }
  scope :member, -> { where(role: "member") }
  scope :viewer, -> { where(role: "viewer") }

  validates :user,
            on: :add_member,
            uniqueness: {
              scope: :space_id,
              message: "is already a member"
            }

  enum role: {
         admin: "admin",
         member: "member",
         viewer: "viewer",
         owner: "owner"
       }
end
