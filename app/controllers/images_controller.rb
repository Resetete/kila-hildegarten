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
      redirect_to images_path, notice: 'Bild wurde erfolgreich hochgeladen'
    else
      render 'new'
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to images_path, notice: 'Bild wurde erfolgreich gelöscht'
  end

  private

  def image_params
    params.require(:image).permit(:name, :picture, :page)
  end
end
