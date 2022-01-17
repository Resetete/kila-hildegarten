class TeamMembersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_team_member, only: [:edit, :update, :destroy]

  def new
    @team_member = TeamMember.new
    @team_member.build_content
    @team_member.build_image
  end

  def create
    @team_member = TeamMember.new(team_member_params)
    @team_member.image.name = team_member_params[:name]
    if @team_member.save
      redirect_to team_path, notice: 'Teammitglied wurde erfolgreich erstellt'
    else
      render 'new'
    end
  end

  def edit
    @team_member.build_image if @team_member.image.nil?
  end

  def update
    if @team_member.update_attributes(team_member_params)
      @team_member.image = Image.new if @team_member.image.nil?
      redirect_to team_path, notice: 'Teammitglied wurde erfolgreich aktualisiert.'
    else
      render 'edit'
    end
  end

  def destroy
    @team_member.image.destroy
    @team_member.content.destroy
    @team_member.destroy
    redirect_to team_path, notice: 'Teammitglied wurde erfolgreich gelöscht.'
  end

  private

  def set_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(
      :name,
      content_attributes: [:id, :page, :content],
      image_attributes: [:id, :picture, :page]
    )
  end
end
