class WeblingPhotosController < ApplicationController
  layout 'bare'

  before_action :authorize_webling_user

  def index; end

  private

  def authorize_webling_user
    user = Admin.find_by(auth_token: params[:token])

    unless user && user.webling_user?
      redirect_to(root_path, status: :unauthorized, alert: 'Unauthorized')
    end
  end
end
