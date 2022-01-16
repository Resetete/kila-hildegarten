class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.all
  end

  def new
    @team_member = TeamMember.new
    @team_member.contents.build
    @team_member.images.build
  end

  def create
    @team_member = TeamMember.new(team_member_params)
    @team_member.images.last.name = team_member_params[:name]
    if @team_member.save
      redirect_to team_members_path
    end
  end

  private

  def team_member_params
    params.require(:team_member).permit(
      :name,
      contents_attributes: [:id, :page, :content],
      images_attributes: [:id, :picture, :page]
    )
  end
end
