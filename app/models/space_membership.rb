class SpaceMembership < ApplicationRecord
  belongs_to :user
  belongs_to :space, touch: true

  enum :role, {
    admin: "admin",
    member: "member",
    viewer: "viewer"
  }, validate: true

  validates :user, presence: true, on: :add_member
  validates :user, uniqueness: { scope: :space_id, message: "is already a member" }
  validates :role, presence: true
  validate :user_is_not_owner

  after_create_commit :broadcast_create_later
  after_destroy_commit :broadcast_destroy

  private
    def user_is_not_owner
      errors.add(:user, "already owns this space") if user && space&.owned_by?(user)
    end

    def broadcast_create_later
      broadcast_render_later_to user, partial: "spaces/create", locals: { space: space, user: user }
    end

    def broadcast_destroy
      broadcast_render_to user, partial: "spaces/destroy", locals: { space: space }
    end
end
