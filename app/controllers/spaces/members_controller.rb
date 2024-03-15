class Spaces::MembersController < ApplicationController
  before_action :set_space
  before_action :verify_owner, only: %i[new create]

  def index
    @members =
      @space
        .space_memberships
        .includes(:user)
        .order("users.name ASC, space_memberships.id ASC")
  end

  def new
    @member = @space.space_memberships.new
  end

  def create
    @member =
      @space.new_member(email: member_params[:user], role: member_params[:role])

    if @member.save(context: :add_member)
      flash[:success] = "Member was successfully added"
      redirect_to space_members_path(@space.slug), status: :see_other
    else
      flash.now[:error] = @member
        .errors
        .full_messages
        .to_sentence
        .downcase
        .capitalize
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    membership = @space.space_memberships.find(params[:id])

    unless Current.user.id == membership.user_id || owner?(@space)
      flash[:error] = "Insufficient permissions"
      redirect_to space_path(@space.slug), status: :see_other
      return
    end

    membership.destroy!

    flash[:success] = "Member was successfully removed"
    redirect_to space_members_path(@space.slug), status: :see_other
  end

  private

  # uses slug because path will be displayed
  def set_space
    @space = Current.user.spaces.find_by(slug: params[:space_id])

    return if @space

    flash[:error] = "Space does not exist"
    redirect_to root_path, status: :see_other
  end

  def member_params
    params.require(:space_membership).permit(:user, :role)
  end

  def verify_owner
    return if owner?(@space)

    flash[:error] = "Insufficient permissions"
    redirect_to space_path(@space.slug), status: :see_other
  end
end
