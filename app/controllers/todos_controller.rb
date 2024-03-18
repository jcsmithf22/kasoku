class TodosController < ApplicationController
  before_action :set_space
  before_action :set_todo, only: %i[update destroy]

  def create
    @todo = @space.todos.new(todo_params)
    respond_to do |format|
      if @todo.save
        format.html { redirect_to space_path(@space.slug) }
        format.turbo_stream
      else
        format.html do
          @todos = @space.todos.order(id: :desc)
          render "spaces/show", status: :unprocessable_entity
        end
        format.turbo_stream { render "error" }
      end
    end
  end

  def update
    @todo.update!(todo_params)

    respond_to do |format|
      format.html { redirect_to space_path(@space.slug) }
      format.turbo_stream
    end
  end

  def destroy
    @todo.destroy!

    respond_to do |format|
      format.html { redirect_to space_path(@space.slug) }
      format.turbo_stream
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:name, :completed)
  end

  # uses space id rather than slug
  def set_space
    @space = Current.user.spaces.find(params[:space_id])
  rescue ActiveRecord::RecordNotFound
    # flash[:error] = "Space does not exist"
    # redirect_to root_path, status: :see_other
    render "errors/show", status: :unprocessable_entity
  end

  def set_todo
    @todo = @space.todos.find(params[:id])
  end
end
