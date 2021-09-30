class ContentController < ApplicationController
  def new
  end

  def edit
    @content = Content.find(1)
  end
end
