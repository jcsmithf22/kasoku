class Users::MembersController < ApplicationController
  def destroy
    membership = Current.user.space_memberships.find_by(space_id: params[:id])

    unless membership.owner?
      membership.destroy!

      flash[:success] = "You have left the space"
      redirect_to root_path, status: :see_other
    else
      flash[:error] = "You are the owner"
      redirect_to space_path(params[:slug])
    end
  end
end
