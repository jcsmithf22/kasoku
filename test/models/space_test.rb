require "test_helper"
require "turbo/broadcastable/test_helper"

class SpaceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup { @space = spaces(:one) }

  test "requires a name and owner" do
    space = Space.new

    assert_not space.valid?
    assert_includes space.errors.attribute_names, :name
    assert_includes space.errors.attribute_names, :owner
  end

  test "ownership does not require a membership" do
    assert @space.owned_by?(users(:one))
    assert_not @space.owned_by?(users(:two))
    assert_not @space.owned_by?(nil)
    assert_empty @space.space_memberships
    assert_equal "owner", @space.my_role(users(:one).id)
    assert_nil @space.my_role(users(:two).id)
  end

  test "owners and members can edit but viewers and unrelated users cannot" do
    assert @space.editable_by?(users(:one))
    assert_not @space.editable_by?(users(:two))

    membership = @space.space_memberships.create!(user: users(:two), role: "member")
    assert @space.editable_by?(users(:two))
    assert_equal "member", @space.my_role(users(:two).id)

    membership.update!(role: "viewer")
    assert_not @space.editable_by?(users(:two))
    assert_equal "viewer", @space.reload.my_role(users(:two).id)
  end

  test "accessible spaces include owned and joined spaces" do
    user = users(:one)
    assert_equal [ @space ], Space.accessible_to(user).to_a

    membership = spaces(:two).space_memberships.create!(user: user, role: "viewer")
    assert_equal [ @space.id, spaces(:two).id ].sort, Space.accessible_to(user).ids.sort

    membership.destroy!
    assert_equal [ @space ], Space.accessible_to(user).to_a
  end

  test "builds a member from an email and role" do
    membership = @space.new_member(email: users(:two).email_address, role: "viewer")

    assert_predicate membership, :new_record?
    assert_equal @space, membership.space
    assert_equal users(:two), membership.user
    assert_equal "viewer", membership.role
  end

  test "unknown email builds an invalid member" do
    membership = @space.new_member(email: "unknown@example.com", role: "member")

    assert_not membership.valid?(:add_member)
    assert_includes membership.errors.attribute_names, :user
  end

  test "completion counts todos and truncates the percentage" do
    @space.todos.create!(name: "Done", completed: true)
    @space.todos.create!(name: "Pending")

    assert_equal({ completed: 1, count: 3, percentage: 33 }, @space.completion)
  end

  test "completion is zero for an empty space" do
    space = users(:one).owned_spaces.create!(name: "Empty")

    assert_equal({ completed: 0, count: 0, percentage: 0 }, space.completion)
  end

  test "destroying a space destroys its todos and memberships" do
    membership = @space.space_memberships.create!(user: users(:two), role: "member")
    todo = todos(:one)

    @space.destroy!

    assert_not Todo.exists?(todo.id)
    assert_not SpaceMembership.exists?(membership.id)
  end

  test "creation broadcasts the space to its owner" do
    space = users(:one).owned_spaces.new(name: "New space")
    streams = capture_turbo_stream_broadcasts users(:one) do
      perform_enqueued_jobs { space.save! }
    end

    assert_equal [ "prepend" ], streams.map { |stream| stream["action"] }
    assert_equal "spaces", streams.first["target"]
    assert streams.first.at_css("template #space_#{space.id}")
    assert_includes streams.first.text, "New space"
  end

  test "destruction broadcasts removal to its owner" do
    streams = capture_turbo_stream_broadcasts users(:one) do
      @space.destroy!
    end

    assert_equal [ "remove" ], streams.map { |stream| stream["action"] }
    assert_equal "space_#{@space.id}", streams.first["target"]
  end

  test "information updates refresh details but not members" do
    assert_no_broadcasts "#{@space.slug}_members" do
      streams = capture_turbo_stream_broadcasts [ @space, :details ] do
        perform_enqueued_jobs { @space.update!(name: "Updated") }
      end
      assert_equal [ "refresh" ], streams.map { |stream| stream["action"] }
    end
  end
end
