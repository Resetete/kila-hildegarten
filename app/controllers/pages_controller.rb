class PagesController < ApplicationController
  def home
    @main_content = Content.find_by(page: 'Home')
    @jobs = Content.find_by(page: 'Stellenausschreibung')
    @kila_free_positions = Content.find_by(page: 'Freie Plätze')
    @images = Image.where(page: 'Home').last(2) # max number of images shown on home page
  end

  def about_us
    @main_content = Content.find_by(page: 'Wir über uns')
  end
end
