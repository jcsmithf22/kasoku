class TodosController < ApplicationController
  before_action :set_space
  before_action :set_todo, only: %i[update destroy]

  def create
    @todo = @space.todos.new(todo_params)

    respond_to do |format|
      if @todo.save
        format.html { redirect_to @space }
        format.turbo_stream
      else
        format.html do
          @todos = @space.todos.order(id: :desc)
          render "spaces/show", status: :unprocessable_entity
        end
        format.turbo_stream { render :error }
      end
    end
  end

  def update
    @todo.update!(todo_params)

    respond_to do |format|
      format.html { redirect_to @space }
      format.turbo_stream
    end
  end

  def destroy
    @todo.destroy!

    respond_to do |format|
      format.html { redirect_to @space }
      format.turbo_stream
    end
  end

  private
    def todo_params
      params.expect(todo: [ :name, :completed ])
    end

    def set_space
      @space = Current.user.spaces.find_by(slug: params[:space_id]) || Current.user.spaces.find_by(id: params[:space_id])
      render "errors/show", status: :unprocessable_entity unless @space
    end

    def set_todo
      @todo = @space.todos.find(params[:id])
    end
end
