class SpacesController < ApplicationController
  # allow_unauthenticated only: :index
  before_action :set_space, only: %i[show destroy]

  def index
    load_spaces
    @space = Current.user.owned_spaces.new
  end

  def create
    @space = Current.user.owned_spaces.new(space_params)

    respond_to do |format|
      if @space.save
        @space.space_memberships.create(user: Current.user, role: "owner")
        format.html do
          redirect_to space_path(@space.slug),
                      status: :see_other,
                      notice: "Space was successfully created."
        end
        format.turbo_stream
      else
        format.html do
          load_spaces
          render :index, status: :unprocessable_entity
        end
        format.turbo_stream { render "error" }
      end
    end
  end

  def show
    @todo = @space.todos.new
  end

  def destroy
    @space.destroy!

    flash[:info] = "Space was successfully destroyed."

    redirect_to root_path, status: :see_other

    # this will be needed if we delete from the spaces index page

    # respond_to do |format|
    #   format.html do
    #     redirect_to spaces_path,
    #                 status: :see_other,
    #                 notice: "Space was successfully destroyed."
    #   end
    #   format.turbo_stream
    # end
  end

  private

  def set_space
    @space = Current.user.spaces.find_by(slug: params[:id])
  end

  def load_spaces
    @spaces = Current.user.spaces.includes(:space_memberships).order(id: :desc)
  end

  def space_params
    params.require(:space).permit(:name, :description)
  end
end
