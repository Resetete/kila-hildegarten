class PagesController < ApplicationController
  def home
    @main_content = Content.find_by(page: 'Home').content
    @jobs = Content.find_by(page: 'Stellenausschreibung')&.content
    @kila_free_positions = Content.find_by(page: 'Freie Plätze')&.content
  end
end
