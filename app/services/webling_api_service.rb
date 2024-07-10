class WeblingApiService
  require 'faraday'
  BASE_URL = 'https://hildegarten.webling.ch'.freeze

  def initialize
    @api_key = Rails.application.credentials.dig(:webling, :api_key)
  end

  def subfolders_with_photo_ids
    Rails.cache.fetch('subfolders_with_photo_ids', expires_in: 12.hours) do
      subfolder_ids.map do |folder_id|
        raw = request_photos_per_subfolder(folder_id)
        next unless raw

        photo_ids = raw.dig('children', 'document').flatten# .first(10) # for debugging get only first photos
        photo_objects = photo_ids.map { |photo_id| get_photo_object(photo_id) }
        raw[:photo_objects] = photo_objects
        raw
      end.compact
    end
  end

  def get_photo_object(photo_id)
    response = conn.get("/api/1/document/#{photo_id}")
    return unless response.success?

    photo = response.body
    photo['id'] = photo_id
    photo
  end

  private

  def subfolder_ids
    @subfolders ||= get_public_photos_documentgroups&.dig('children', 'documentgroup') || []
  end

  def request_photos_per_subfolder(folder)
    response = conn.get("/api/1/documentgroup/#{folder}?order=title ASC&format=full")

    return unless response.success?

    response.body
  end

  def get_public_photos_documentgroups
    response = conn.get('/api/1/documentgroup/295')

    return unless response.success?

    response.body
  end

  def conn
    @conn ||= Faraday.new(url: BASE_URL) do |faraday|
      faraday.headers['apikey'] = @api_key
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end
  end
end
