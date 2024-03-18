class Spaces::DetailsController < ApplicationController
  before_action :set_space

  def index
    store_last_page
    @completion_stats = @space.completion
  end

  private

  # uses slug because path will be displayed
  def set_space
    @space = Current.user.spaces.find_by(slug: params[:space_id])

    return if @space

    # flash[:error] = "Space does not exist"
    # redirect_to root_pathstatus: :see_other
    render "errors/show", status: :unprocessable_entity
  end
end
