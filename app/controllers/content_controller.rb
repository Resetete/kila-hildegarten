class ContentController < ApplicationController
  def index
    @page_contents = Content.all
  end

  def new
    p "controller: #{Content.all}"
    @content = Content.all.first
  end

  def edit
    p "controller: #{Content.all}"
    @content = Content.all.first
  end
end
