class ImagesController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @images = Image.all
  end

  # Number of max images should be limited thought carrierwave + check security
  def new
    @image = Image.new(page: params[:page])
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      # TODO: show a success message
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    # TODO: show a message after deletion
    redirect_to images_path
  end

  private

  def image_params
    params.require(:image).permit(:name, :picture, :page)
  end
end
