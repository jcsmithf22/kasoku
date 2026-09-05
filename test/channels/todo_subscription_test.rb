require "test_helper"

class TodoSubscriptionTest < ActionCable::Channel::TestCase
  include ActiveJob::TestHelper

  tests Turbo::StreamsChannel

  test "an existing subscription stops receiving todo updates after membership removal" do
    skip "Pending fix for removed members retaining Todo subscriptions"

    space = spaces(:one)
    member = users(:two)
    membership = space.space_memberships.create!(user: member, role: "member")
    todo = todos(:one)
    stream = space.to_gid_param

    stub_connection current_user: member
    @subscription = self.class.channel_class.new(connection, "todos", {
      signed_stream_name: Turbo::StreamsChannel.signed_stream_name(space)
    }.with_indifferent_access)

    # The usual subscribe helper replaces stream_from with a bookkeeping stub.
    # Keep the real channel's handlers, but deliver broadcasts synchronously below
    # instead of using pub/sub and the worker pool. No socket or browser is needed.
    subscription.define_singleton_method(:stream_from) do |broadcasting, callback = nil, coder: nil, &block|
      streams[String(broadcasting)] = stream_handler(String(broadcasting), callback || block, coder: coder)
    end
    subscription.subscribe_to_channel
    assert subscription.send(:subscription_confirmation_sent?)

    deliver_todo_update(todo, stream, "Visible before removal")
    assert_equal 1, transmissions.size
    assert_includes transmissions.last, "Visible before removal"

    membership.destroy!
    assert_not_includes member.accessible_spaces, space

    assert_no_difference -> { transmissions.size }, "Removed member received a Todo update on the existing subscription" do
      deliver_todo_update(todo, stream, "Private after removal")
    end
  ensure
    subscription&.unsubscribe_from_channel
  end

  private
    def deliver_todo_update(todo, stream, name)
      clear_messages(stream)
      perform_enqueued_jobs { todo.update!(name: name) }

      messages = broadcasts(stream)
      assert_equal 1, messages.size, "The Todo update must still be broadcast for authorized subscribers"
      messages.each do |message|
        subscription.send(:streams)[stream]&.call(message)
      end
    end
end
