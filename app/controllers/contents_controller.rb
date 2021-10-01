class ContentsController < ApplicationController
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

  def edit
    @content = Content.find(params[:id])
  end

  def update
    @content = Content.find(params[:id])
    if @content.update(content_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

  def content_params
    params.require(:content).permit(:content, :page)
  end
end
