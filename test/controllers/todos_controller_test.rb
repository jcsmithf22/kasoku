require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space = spaces(:one)
    sign_in_as users(:one)
  end

  test "create as HTML" do
    assert_difference "Todo.count", 1 do
      post space_todos_path(@space), params: { todo: { name: "New Todo" } }
    end

    assert_redirected_to @space
    assert_equal "New Todo", @space.todos.order(:id).last.name
  end

  test "create as Turbo Stream" do
    assert_difference "Todo.count", 1 do
      post space_todos_path(@space), params: { todo: { name: "New Todo" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "create validation failure as HTML" do
    assert_no_difference "Todo.count" do
      post space_todos_path(@space), params: { todo: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "create validation failure as Turbo Stream" do
    assert_no_difference "Todo.count" do
      post space_todos_path(@space), params: { todo: { name: "" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "update as HTML" do
    patch space_todo_path(@space, todos(:one)), params: { todo: { name: "Updated" } }

    assert_redirected_to @space
    assert_equal "Updated", todos(:one).reload.name
  end

  test "update as Turbo Stream" do
    patch space_todo_path(@space, todos(:one)),
      params: { todo: { completed: true } },
      as: :turbo_stream

    assert_response :success
    assert todos(:one).reload.completed?
  end

  test "destroy as HTML" do
    assert_difference "Todo.count", -1 do
      delete space_todo_path(@space, todos(:one))
    end

    assert_redirected_to @space
  end

  test "destroy as Turbo Stream" do
    assert_difference "Todo.count", -1 do
      delete space_todo_path(@space, todos(:one)), as: :turbo_stream
    end

    assert_response :success
  end

  test "member can mutate todos" do
    @space.space_memberships.create!(user: users(:two), role: "member")
    sign_in_as users(:two)

    assert_difference "Todo.count", 1 do
      post space_todos_path(@space), params: { todo: { name: "Member Todo" } }
    end

    assert_redirected_to @space
  end

  test "viewer cannot mutate todos" do
    todo = todos(:one)
    @space.space_memberships.create!(user: users(:two), role: "viewer")
    sign_in_as users(:two)

    assert_no_difference "Todo.count" do
      post space_todos_path(@space), params: { todo: { name: "Forbidden" } }
    end
    assert_response :forbidden

    patch space_todo_path(@space, todo), params: { todo: { name: "Forbidden" } }
    assert_response :forbidden
    assert_equal "One Todo", todo.reload.name

    assert_no_difference "Todo.count" do
      delete space_todo_path(@space, todo)
    end
    assert_response :forbidden
  end

  test "todo lookup is scoped to the space" do
    patch space_todo_path(@space, todos(:two)), params: { todo: { name: "Wrong space" } }

    assert_response :not_found
    assert_equal "Two Todo", todos(:two).reload.name
  end
end
