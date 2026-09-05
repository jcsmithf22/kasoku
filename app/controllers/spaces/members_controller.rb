class Spaces::MembersController < ApplicationController
  before_action :set_space
  before_action :verify_owner, only: %i[new create]

  def index
    @members = @space.space_memberships.includes(:user).order("users.first_name ASC, users.last_name ASC, space_memberships.id ASC")
  end

  def new
    @member = @space.space_memberships.new
    @back_to_members = params[:from]
  end

  def create
    @back_to_members = member_params[:from]
    @member = @space.new_member(email: member_params[:user], role: member_params[:role])

    if @member.save(context: :add_member)
      redirect_to after_add_member_path, status: :see_other, notice: "Member was successfully added"
    else
      flash.now[:alert] = @member.errors.full_messages.to_sentence.downcase.capitalize
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    membership = @space.space_memberships.find(params[:id])

    unless Current.user.id == membership.user_id || @space.owned_by?(Current.user)
      redirect_to @space, status: :see_other, alert: "Insufficient permissions"
      return
    end

    membership.destroy!
    redirect_to space_members_path(@space), status: :see_other, notice: "Member was successfully removed"
  end

  private
    def set_space
      @space = Current.user.accessible_spaces.find_by(slug: params[:space_id])
      render "errors/show", status: :unprocessable_entity unless @space
    end

    def member_params
      params.expect(space_membership: [ :user, :role, :from ])
    end

    def verify_owner
      return if @space.owned_by?(Current.user)

      redirect_to @space, status: :see_other, alert: "Insufficient permissions"
    end

    def after_add_member_path
      case member_params[:from]
      when "members"
        space_members_path(@space)
      else
        @space
      end
    end
end
