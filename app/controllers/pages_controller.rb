class PagesController < ApplicationController
  def home
    # TODO: refactor --> maybe looping over array with page names
    # TODO: reduce image size --> image uploader

    Page::NAMES.each do |page_name|
      instance_variable_set "@#{page_name}", page_content_retriever(page_name)
    end

    @home_images = Image.where(page: 'home').last(Image::MAX_IMAGES_ON_HOMEPAGE) # max number of images shown on home page
    @daily_life_images = Image.where(page: 'daily_life').last(Image::MAX_IMAGES_ON_HOMEPAGE)
    @rooms_images = Image.where(page: 'rooms')
  end

  def contact
    @main_content = Content.find_by(page: 'contact')
  end

  private

  def page_content_retriever(page)
    Content.find_by(page: page)
  end
end
