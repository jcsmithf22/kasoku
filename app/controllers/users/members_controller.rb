class Users::MembersController < ApplicationController
  before_action :set_membership

  def destroy
    @membership.destroy!
    redirect_to root_path, status: :see_other, notice: "You have left the space"
  end

  private
    def set_membership
      @membership = Current.user.space_memberships.find_by(space_id: params[:id])
      render "errors/show", status: :unprocessable_entity unless @membership
    end
end
