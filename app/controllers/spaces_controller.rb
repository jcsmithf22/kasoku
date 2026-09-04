class SpacesController < ApplicationController
  before_action :set_space, only: %i[show destroy]
  before_action :verify_owner, only: :destroy

  def index
    load_spaces
    @space = Current.user.owned_spaces.new
  end

  def create
    @space = Current.user.owned_spaces.new(space_params)

    respond_to do |format|
      if @space.save
        @space.space_memberships.create(user: Current.user, role: "owner")
        format.html { redirect_to @space, status: :see_other, notice: "Space was successfully created." }
        format.turbo_stream
      else
        format.html do
          load_spaces
          render :index, status: :unprocessable_entity
        end
        format.turbo_stream { render :error }
      end
    end
  end

  def show
    store_last_page
    @todo = Todo.new
    @todos = @space.todos.order(id: :desc)
  end

  def destroy
    @space.destroy!

    redirect_to root_path, status: :see_other, notice: "Space was successfully destroyed."
  end

  private
    def set_space
      @space = Current.user.spaces.find_by(slug: params[:id])
      render "errors/show", status: :unprocessable_entity unless @space
    end

    def load_spaces
      @spaces = Current.user.spaces.includes(:space_memberships).order(id: :desc)
    end

    def space_params
      params.expect(space: [ :name, :description ])
    end

    def verify_owner
      return if @space.owned_by?(Current.user)

      redirect_to @space, status: :see_other, alert: "Insufficient permissions"
    end
end
