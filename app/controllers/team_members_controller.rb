class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.all
  end

  def new
    @team_member = TeamMember.new
  end

  def create
    @team_member = TeamMember.new(team_member_params)
    p '********'
    p "params"
    p params
    p @team_member
    if @team_member.save
      redirect_to team_members_path
    end
  end

  private

  def team_member_params
    params.require(:team_member).permit(
      :name,
      contents_attributes: [:id, :page, :content]
    )
  end
end
