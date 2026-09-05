require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space = spaces(:one)
    sign_in_as users(:one)
  end

  test "creates a todo via Turbo" do
    assert_difference("Todo.count") do
      post space_todos_url(@space),
           params: { todo: { name: "New Todo" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end

  test "completes a todo via Turbo" do
    todo = todos(:one)

    patch space_todo_url(@space, todo),
          params: { todo: { completed: true } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert todo.reload.completed?
  end

  test "viewers receive shared markup but cannot write todos" do
    get space_url(@space)
    assert_select ".todos--editable", count: 1
    owner_stream = css_select("turbo-cable-stream-source").first["signed-stream-name"]
    @space.space_memberships.create!(user: users(:two), role: "viewer")
    sign_in_as users(:two)

    get space_url(@space)
    assert_response :success
    assert_select ".todos--readonly .todo-editable"
    assert_select ".todos--readonly .todo-status"
    assert_equal owner_stream, css_select("turbo-cable-stream-source").first["signed-stream-name"]

    todo = todos(:one)
    [ "text/html", "text/vnd.turbo-stream.html" ].each do |accept|
      headers = { "Accept" => accept }
      assert_no_difference "Todo.count" do
        post space_todos_url(@space), params: { todo: { name: "Forbidden" } }, headers: headers
        assert_response :forbidden
        delete space_todo_url(@space, todo), headers: headers
        assert_response :forbidden
      end
      patch space_todo_url(@space, todo), params: { todo: { name: "Forbidden", completed: true } }, headers: headers
      assert_response :forbidden
      assert_equal "One Todo", todo.reload.name
      assert_not todo.completed?
    end
  end

  test "members can create edit complete and delete todos" do
    @space.space_memberships.create!(user: users(:two), role: "member")
    sign_in_as users(:two)
    get space_url(@space)
    assert_select ".todos--editable", count: 1

    assert_difference "Todo.count", 1 do
      post space_todos_url(@space), params: { todo: { name: "Member todo" } }
      assert_redirected_to @space
    end
    todo = @space.todos.find_by!(name: "Member todo")
    patch space_todo_url(@space, todo), params: { todo: { name: "Edited", completed: true } }
    assert_redirected_to @space
    assert_equal "Edited", todo.reload.name
    assert todo.completed?
    assert_difference "Todo.count", -1 do
      delete space_todo_url(@space, todo)
      assert_redirected_to @space
    end
  end
end
