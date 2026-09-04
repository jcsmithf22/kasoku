class Users::MembersController < ApplicationController
  before_action :set_membership

  def destroy
    if @membership.owner?
      redirect_to space_path(params[:slug] || @membership.space.slug), alert: "You are the owner"
    else
      @membership.destroy!
      redirect_to root_path, status: :see_other, notice: "You have left the space"
    end
  end

  private
    def set_membership
      @membership = Current.user.space_memberships.find_by(space_id: params[:id])
      render "errors/show", status: :unprocessable_entity unless @membership
    end
end
