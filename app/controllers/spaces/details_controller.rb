class Spaces::DetailsController < ApplicationController
  before_action :set_space

  def index
    store_last_page
    @completion_stats = @space.completion
  end

  private
    def set_space
      @space = Current.user.spaces.find_by(slug: params[:space_id])
      render "errors/show", status: :unprocessable_entity unless @space
    end
end
