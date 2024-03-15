class SpaceMembership < ApplicationRecord
  belongs_to :user
  belongs_to :space, touch: true

  scope :admin, -> { where(role: "admin") }
  scope :member, -> { where(role: "member") }
  scope :viewer, -> { where(role: "viewer") }

  validates :user,
            on: :add_member,
            uniqueness: {
              scope: :space_id,
              message: "is already a member"
            }

  validates :role, presence: true

  enum role: {
         admin: "admin",
         member: "member",
         viewer: "viewer",
         owner: "owner"
       }

  # after_destroy_commit :broadcast_remove

  # private

  # def broadcast_remove
  #   broadcast_refresh_to "#{user_id}_membership_from_#{space_id}_removed"
  # end
end
