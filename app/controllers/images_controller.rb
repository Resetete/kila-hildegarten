class ImagesController < ApplicationController
  before_action :authenticate_admin!

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def image_params
    params.require(:image).permit(:name, :picture, :page)
  end
end
