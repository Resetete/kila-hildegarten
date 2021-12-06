class PagesController < ApplicationController
  def home
    # TODO: refactor --> maybe looping over array with page names
    # TODO: improve page names
    # TODO: reduce image size --> image uploader
    @main_content = Content.find_by(page: 'Home')
    @jobs = Content.find_by(page: 'Stellenausschreibung')
    @kila_free_positions = Content.find_by(page: 'Freie Plätze')
    @about_us = Content.find_by(page: 'Über uns')
    @daily_life_intro = Content.find_by(page: 'Tagesablauf Einführung')
    @daily_life = Content.find_by(page: 'Tagesablauf')

    @images = Image.where(page: 'Home').last(Image::MAX_IMAGES_ON_HOMEPAGE) # max number of images shown on home page
    @daily_life_images = Image.where(page: 'daily_life_image').last(Image::MAX_IMAGES_ON_HOMEPAGE)
  end

  def contact
    @main_content = Content.find_by(page: 'Kontakt')
  end
end
