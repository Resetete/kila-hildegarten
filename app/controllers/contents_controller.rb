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
  end

  private

  def content_params
    params.require(:content).permit(:content, :page)
  end
end
