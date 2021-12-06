class PagesController < ApplicationController
  def home
    # TODO: refactor --> maybe looping over array with page names
    # TODO: reduce image size --> image uploader
    @main_content = Content.find_by(page: 'home')
    @jobs = Content.find_by(page: 'open_positions')
    @kila_free_positions = Content.find_by(page: 'open_places')
    @about_us = Content.find_by(page: 'about_us')
    @daily_life_intro = Content.find_by(page: 'daily_life_intro')
    @daily_life = Content.find_by(page: 'daily_life')
    @rooms = Content.find_by(page: 'rooms')
    @concept = Content.find_by(page: 'concept')
    @familarization = Content.find_by(page: 'familarization')

    @home_images = Image.where(page: 'home').last(Image::MAX_IMAGES_ON_HOMEPAGE) # max number of images shown on home page
    @daily_life_images = Image.where(page: 'daily_life').last(Image::MAX_IMAGES_ON_HOMEPAGE)
    @rooms_images = Image.where(page: 'rooms')
  end

  def contact
    @main_content = Content.find_by(page: 'contact')
  end
end
