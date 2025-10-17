class WeblingPhotosController < ApplicationController
  # before_action :authorize_webling_user
  before_action :allow_iframe_for_webling_photos, only: [:index]

  layout 'bare'

  def index
    @subfolders_with_photo_ids = WeblingApiService.new.subfolders_with_photo_ids

    @subfolders_with_photo_ids.each do |folder|
      folder[:photo_objects].each do |photo|
        WeblingPhotoCacheService.new(photo_id: photo[:id]).fetch_or_store! unless WeblingFile.exists?(webling_id: photo[:id])
      end
    end
  end

  # returns the original file
  def show
    file = find_or_cache_file(params[:id])
    return head :not_found unless file&.file&.attached?

    redirect_to url_for(file.file)
  end

  # returns a thumbnail photo (300pxx300px)
  def thumbnail
    file = WeblingFile.find_by(webling_id: params[:id])

    unless file&.file&.attached?
      WeblingPhotoCacheService.new(photo_id: params[:id]).fetch_or_store!
      file = WeblingFile.find_by(webling_id: params[:id])
    end

    if file&.file&.attached?
      blob = file.file.blob

      # cloudinary transforms the images to thumbnails
      variant = if blob.image?
        file.file.variant(resize_to_limit: [300, 300])
      else
        file.file.preview(resize_to_limit: [300, 300])
      end

      redirect_to url_for(variant)
    else
      head :not_found
    end
  end

  private

  # retrieves the file from the db if exisiting
  # or retrieves the file from webling via API and cache service
  def find_or_cache_file(photo_id)
    WeblingFile.find_by(webling_id: photo_id).tap do |file|
      next if file&.file&.attached?
      WeblingPhotoCacheService.new(photo_id: photo_id).fetch_or_store!
    end
  end

  def authorize_webling_user
    user = Admin.find_by(auth_token: params[:token]) || current_user.webling_user?
    unless user&.webling_user?
      redirect_to(root_path, status: :unauthorized, alert: 'Unauthorized')
    end
  end

  def allow_iframe_for_webling_photos
    response.headers['Content-Security-Policy'] = "frame-ancestors 'self' https://hildegarten.webling.eu"
  end
end
