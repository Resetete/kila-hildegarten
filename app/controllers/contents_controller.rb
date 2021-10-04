class ContentsController < ApplicationController
  before_action :set_content, only: [:edit, :update, :destroy]
  before_action :authenticate_admin!

  def index
    @page_contents = Content.all
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(content_params)
    @content.save
    redirect_to root_path
  end

  def edit; end

  def update
    if @content.update(content_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def destroy
    @content.destroy
    redirect_to root_path
  end

  private

  def content_params
    params.require(:content).permit(:content, :page)
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
