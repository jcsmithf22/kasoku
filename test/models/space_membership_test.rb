require "test_helper"
require "turbo/broadcastable/test_helper"

class SpaceMembershipTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup do
    @membership = spaces(:one).space_memberships.new(user: users(:two), role: "member")
  end

  test "requires a user space and role" do
    membership = SpaceMembership.new(role: nil)

    assert_not membership.valid?(:add_member)
    assert_includes membership.errors.attribute_names, :user
    assert_includes membership.errors.attribute_names, :space
    assert_includes membership.errors.attribute_names, :role
  end

  test "accepts member and viewer roles only" do
    %w[member viewer].each do |role|
      @membership.role = role
      assert @membership.valid?
    end

    %w[owner admin unknown].each do |role|
      @membership.role = role
      assert_not @membership.valid?
      assert_includes @membership.errors.attribute_names, :role
    end
  end

  test "a user can only join a space once" do
    @membership.save!
    duplicate = spaces(:one).space_memberships.new(user: users(:two), role: "viewer")

    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :user
  end

  test "the owner cannot join their own space" do
    @membership.user = users(:one)

    assert_not @membership.valid?
    assert_includes @membership.errors[:user], "already owns this space"
  end

  test "addition broadcasts the space and role to the member" do
    streams = capture_turbo_stream_broadcasts users(:two) do
      perform_enqueued_jobs { @membership.save! }
    end

    assert_equal [ "prepend" ], streams.map { |stream| stream["action"] }
    assert_equal "spaces", streams.first["target"]
    assert streams.first.at_css("template #space_#{@membership.space_id}")
    assert_includes streams.first.text, @membership.space.name
    assert_includes streams.first.text, "member"
  end

  test "removal broadcasts space removal to the member" do
    @membership.save!
    streams = capture_turbo_stream_broadcasts users(:two) do
      @membership.destroy!
    end

    assert_equal [ "remove" ], streams.map { |stream| stream["action"] }
    assert_equal "space_#{@membership.space_id}", streams.first["target"]
  end

  test "writes refresh details and members" do
    space = @membership.space

    [ -> { @membership.save! }, -> { @membership.update!(role: "viewer") }, -> { @membership.destroy! } ].each do |write|
      members = capture_turbo_stream_broadcasts "#{space.slug}_members" do
        details = capture_turbo_stream_broadcasts [ space, :details ] do
          perform_enqueued_jobs(&write)
        end
        assert_equal [ "refresh" ], details.map { |stream| stream["action"] }
      end
      assert_equal [ "refresh" ], members.map { |stream| stream["action"] }
    end
  end
end
