class Space < ApplicationRecord
  include PrettySlug

  self.slug_prefix = "spc"

  belongs_to :owner, class_name: "User"
  has_many :space_memberships, dependent: :destroy
  has_many :members, through: :space_memberships, source: :user
  has_many :todos, dependent: :destroy

  validates :name, presence: true

  scope :accessible_to, ->(user) {
    where(owner_id: user.id).or(
      where(id: SpaceMembership.where(user_id: user.id).select(:space_id))
    )
  }

  after_create_commit :broadcast_create_to_owner
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy_to_owner

  def to_param
    slug
  end

  def owned_by?(user)
    owner_id == user&.id
  end

  def my_role(user_id)
    return "owner" if owner_id == user_id

    space_memberships.find { |membership| membership.user_id == user_id }&.role
  end

  def new_member(email:, role:)
    user = User.find_by(email_address: email)
    space_memberships.new(user: user, role: role)
  end

  def completion
    completed_count = todos.completed.count
    count = todos.count

    {
      completed: completed_count,
      count: count,
      percentage: count > 0 ? (completed_count.to_f / count * 100).to_i : 0
    }
  end

  private
    def broadcast_create_to_owner
      broadcast_render_later_to owner, partial: "spaces/create", locals: { space: self, user: owner }
    end

    def broadcast_destroy_to_owner
      broadcast_render_to owner, partial: "spaces/destroy", locals: { space: self }
    end

    def broadcast_update
      broadcast_refresh_later_to "#{slug}_members"
    end
end
