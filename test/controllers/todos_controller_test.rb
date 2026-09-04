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
end
