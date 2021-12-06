class PagesController < ApplicationController
  def home
    @main_content = Content.find_by(page: 'Home')
    @jobs = Content.find_by(page: 'Stellenausschreibung')
    @kila_free_positions = Content.find_by(page: 'Freie Plätze')
    @about_us = Content.find_by(page: 'Über uns')

    @images = Image.where(page: 'Home').last(Image::MAX_IMAGES_ON_HOMEPAGE) # max number of images shown on home page
  end

  def contact
    @main_content = Content.find_by(page: 'Kontakt')
  end
end
