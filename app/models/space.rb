class Space < ApplicationRecord
  include PrettySlug

  self.slug_prefix = "spc"

  belongs_to :owner, class_name: "User"
  has_many :space_memberships, dependent: :destroy
  has_many :members, through: :space_memberships, source: :user
  has_many :todos, dependent: :destroy

  validates :name, presence: true

  after_update_commit :broadcast_update

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
    def broadcast_update
      broadcast_refresh_later_to "#{slug}_members"
    end
end
