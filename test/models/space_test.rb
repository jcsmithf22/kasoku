require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  test "broadcasts creation and destruction to the owner without a membership" do
    owner = users(:one)
    space = nil

    assert_broadcasts owner.to_gid_param, 1 do
      perform_enqueued_jobs(only: Turbo::Streams::BroadcastJob) do
        space = owner.owned_spaces.create!(name: "New Space")
      end
    end

    assert_broadcasts owner.to_gid_param, 1 do
      space.destroy!
    end
  end

  test "accessible spaces include owned and joined spaces but not unrelated spaces" do
    user = users(:one)
    owned = spaces(:one)
    joined = spaces(:two)
    unrelated = users(:two).owned_spaces.create!(name: "Private")
    joined.space_memberships.create!(user: user, role: "member")
    owned.space_memberships.create!(user: users(:two), role: "viewer")

    assert_equal [ owned.id, joined.id ].sort, user.accessible_spaces.ids.sort
    assert_not_includes user.accessible_spaces, unrelated
    assert_equal [ joined ], user.joined_spaces.to_a
    assert_equal [ owned ], user.accessible_spaces.where(id: owned.id).to_a
    assert_equal "owner", owned.my_role(user.id)
    assert_equal "member", joined.my_role(user.id)
    assert_nil unrelated.my_role(user.id)
  end

  test "removing membership revokes joined access but preserves ownership" do
    space = spaces(:one)
    member = users(:two)
    membership = space.space_memberships.create!(user: member, role: "member")

    membership.destroy!

    assert_not_includes member.accessible_spaces, space
    assert_includes space.owner.accessible_spaces, space
  end

  test "owner cannot be added as a member" do
    space = spaces(:one)
    membership = space.space_memberships.new(user: space.owner, role: "admin")

    assert_not membership.save
    assert_includes membership.errors[:user], "already owns this space"
  end

  test "owner is not a membership role" do
    membership = spaces(:one).space_memberships.new(user: users(:two), role: "owner")

    assert_not membership.save(context: :add_member)
    assert_predicate membership.errors[:role], :any?
  end
end
