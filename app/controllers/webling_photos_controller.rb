class WeblingPhotosController < ApplicationController
  layout 'bare'

  before_action :authenticate_admin!

  def index; end
end