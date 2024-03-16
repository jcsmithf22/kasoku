class Users::MembersController < ApplicationController
  before_action :set_membership

  # Leave a space
  def destroy
    unless @membership.owner?
      @membership.destroy!

      flash[:success] = "You have left the space"
      redirect_to root_path, status: :see_other
    else
      flash[:error] = "You are the owner"
      redirect_to space_path(params[:slug])
    end
  end

  private

  def set_membership
    @membership = Current.user.space_memberships.find_by(space_id: params[:id])

    return if @membership

    # flash[:error] = "You are not a member of this space"
    # redirect_to root_path, status: :see_other
    render "errors/show", status: :unprocessable_entity
  end
end
