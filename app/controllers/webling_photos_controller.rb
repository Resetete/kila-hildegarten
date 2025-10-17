class WeblingPhotosController < ApplicationController
  before_action :allow_iframe_for_webling_photos, only: [:index]
  before_action :authorize_webling_user

  layout 'bare'

  def index
    Rails.logger.info "🟢 Loading Webling subfolders..."
    @subfolders_with_photo_ids = WeblingApiService.new.subfolders_with_photo_ids
    existing_ids = WeblingFile.pluck(:webling_id)

    # enqueue background caching for new photos
    @subfolders_with_photo_ids.each do |folder|
      folder[:photo_objects]&.each do |photo|
        next if existing_ids.include?(photo[:id].to_s)
        Rails.logger.info "📸 Enqueuing caching job for photo #{photo[:id]}"
        WeblingPhotoCacheJob.perform_later(photo[:id])
      end
    end

  ensure
    # Ensure that unused db connections are released so that we can schedule new jobs
    ActiveRecord::Base.clear_active_connections!
  end

  # Returns the original file (full-size)
  def show
    file = find_or_cache_file(params[:id])
    return head :not_found unless file&.file&.attached?

    redirect_to url_for(file.file)
  end

  private

  def find_or_cache_file(photo_id)
    WeblingFile.find_by(webling_id: photo_id).tap do |file|
      next if file&.file&.attached?

      WeblingPhotoCacheService.new(photo_id: photo_id).fetch_or_store!
    end
  end

  def authorize_webling_user
    user = Admin.find_by(auth_token: params[:token]) || current_user&.webling_user?
    redirect_to(root_path, status: :unauthorized, alert: 'Unauthorized') unless user&.webling_user?
  end

  def allow_iframe_for_webling_photos
    response.headers['Content-Security-Policy'] = "frame-ancestors 'self' https://hildegarten.webling.eu"
  end
end
