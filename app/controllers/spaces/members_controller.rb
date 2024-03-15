class Spaces::MembersController < ApplicationController
  before_action :set_space

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
    email = member_params[:user]
    user = User.find_by(email: email)

    @member =
      @space.space_memberships.new(user: user, role: member_params[:role])

    if @member.save(context: :add_member)
      flash[:success] = "Member was successfully added"
      redirect_to space_path(@space.slug), status: :see_other
    else
      # @member.errors[:user].each { |error| @member.errors.add(:email, error) }
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
  end

  private

  def set_space
    @space = Current.user.spaces.find_by(slug: params[:space_id])
  end

  def member_params
    params.require(:space_membership).permit(:user, :role)
  end
end
