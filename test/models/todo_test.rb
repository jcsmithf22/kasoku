require "test_helper"
require "turbo/broadcastable/test_helper"

class TodoTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup { @todo = todos(:one) }

  test "requires a name and space" do
    todo = Todo.new

    assert_not todo.valid?
    assert_includes todo.errors.attribute_names, :name
    assert_includes todo.errors.attribute_names, :space
  end

  test "completed and pending scopes follow completion state" do
    assert_includes Todo.pending, @todo
    assert_not_includes Todo.completed, @todo

    @todo.update!(completed: true)

    assert_includes Todo.completed, @todo
    assert_not_includes Todo.pending, @todo
  end

  test "creation broadcasts a new row to the space" do
    todo = spaces(:one).todos.new(name: "New todo")
    streams = capture_turbo_stream_broadcasts todo.space do
      perform_enqueued_jobs { todo.save! }
    end

    assert_equal [ "prepend" ], streams.map { |stream| stream["action"] }
    assert_equal "todos", streams.first["target"]
    assert streams.first.at_css("template #todo_#{todo.id}")
    assert_includes streams.first.text, "New todo"
  end

  test "updating broadcasts the updated row to the space" do
    streams = capture_turbo_stream_broadcasts @todo.space do
      perform_enqueued_jobs { @todo.update!(name: "Finished", completed: true) }
    end

    assert_equal [ "replace" ], streams.map { |stream| stream["action"] }
    assert_equal "todo_#{@todo.id}", streams.first["target"]
    assert_includes streams.first.text, "Finished"
    assert streams.first.at_css("button[aria-pressed='true']")
  end

  test "destruction broadcasts row removal to the space" do
    streams = capture_turbo_stream_broadcasts @todo.space do
      @todo.destroy!
    end

    assert_equal [ "remove" ], streams.map { |stream| stream["action"] }
    assert_equal "todo_#{@todo.id}", streams.first["target"]
  end

  test "writes refresh details but not members" do
    space = spaces(:one)
    todo = space.todos.new(name: "Live todo")

    [ -> { todo.save! }, -> { todo.update!(completed: true) }, -> { todo.destroy! } ].each do |write|
      assert_no_broadcasts "#{space.slug}_members" do
        streams = capture_turbo_stream_broadcasts [ space, :details ] do
          perform_enqueued_jobs(&write)
        end
        assert_equal [ "refresh" ], streams.map { |stream| stream["action"] }
      end
    end
  end
end
