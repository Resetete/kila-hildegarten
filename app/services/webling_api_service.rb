class WeblingApiService
  require 'faraday'
  BASE_URL = 'https://hildegarten.webling.ch'.freeze

  def initialize
    @api_key = Rails.application.credentials.dig(:webling, :api_key)
  end

  def subfolders_with_photo_ids
    last_fetch_timestamp = Rails.cache.read('last_fetch_timestamp') || Date.yesterday.to_time.to_i
    #last_fetch_timestamp = (Time.now - 2.hours).to_i # TODO: remove, just for debugging
    folder_changes = fetch_changes('documentgroup', last_fetch_timestamp)
    photo_changes = fetch_changes('document', last_fetch_timestamp)

    if folder_changes.present? || photo_changes.present?
      updated_subfolders = fetch_updated_subfolders_with_photo_ids(folder_changes, photo_changes)
      cache_subfolders(updated_subfolders)
      updated_subfolders
    else
      Rails.cache.fetch('subfolders_with_photo_ids', expires_in: 12.hours) do
        fetch_subfolders_with_photo_ids
      end
    end
  end

  private

  def fetch_updated_subfolders_with_photo_ids(folder_changes, photo_changes)
    all_subfolders = fetch_subfolders_with_photo_ids

    changed_folder_ids = folder_changes&.map(&:to_i) || []
    changed_photo_ids = photo_changes&.map(&:to_i) || []

    all_subfolders.each do |subfolder|
      subfolder_id = subfolder['id'].to_i
      next unless subfolder.present?

      subfolder_photo_ids = subfolder[:photo_objects].map { |photo| photo['id'].to_i }

      if changed_folder_ids.include?(subfolder_id) || (subfolder_photo_ids & changed_photo_ids).any?
        updated_photos = fetch_photos_in_subfolder(subfolder_id)
        subfolder[:photo_objects] = updated_photos if updated_photos.present?
      end
    end

    all_subfolders
  end

  def fetch_subfolders_with_photo_ids
    subfolder_ids.map { |folder_id| fetch_subfolder_with_photo_ids(folder_id) }.compact
  end

  def fetch_subfolder_with_photo_ids(folder_id)
    raw = request_photos_per_subfolder(folder_id)
    return unless raw && public_kila_photo_folder?(raw)

    photo_ids = raw.dig('children', 'document')
    folder_title = raw.dig('properties', 'title')
    return unless photo_ids

    photo_objects = fetch_photos(photo_ids.flatten) # Adjusted to fetch last 10 photos
    {
      id: folder_id,
      title: folder_title,
      photo_objects: photo_objects
    }
  end

  def fetch_photos_in_subfolder(folder_id)
    raw = request_photos_per_subfolder(folder_id)
    return unless raw && public_kila_photo_folder?(raw)

    photo_ids = raw.dig('children', 'document')
    return [] unless photo_ids

    fetch_photos(photo_ids.flatten)
  end

  def cache_subfolders(subfolders)
    Rails.cache.write('subfolders_with_photo_ids', subfolders, expires_in: 12.hours)
  end

  def fetch_changes(object_type, since_timestamp)
    response = conn.get("/api/1/changes/#{since_timestamp}")

    if response.success?
      Rails.cache.write('last_fetch_timestamp', current_timestamp_in_seconds)
      extract_changed_ids(response.body, object_type)
    else
      Rails.logger.error "Failed to fetch #{object_type} changes: #{response.body}"
      []
    end
  end

  def extract_changed_ids(changes_body, object_type)
    return [] unless changes_body['objects'].any?

    if changes_body['objects'].key?(object_type)
      changes_body['objects'][object_type]
    else
      []
    end
  end

  def current_timestamp_in_seconds
    Time.now.to_i
  end

  def fetch_photos(photo_ids)
    photo_ids.map { |photo_id| { id: photo_id, data: get_photo_object(photo_id) } }
  end

  def get_photo_object(photo_id)
    response = conn.get("/api/1/document/#{photo_id}")
    return unless response.success?

    photo = response.body
    photo['id'] = photo_id
    photo
  end

  def request_photos_per_subfolder(folder)
    response = conn.get("/api/1/documentgroup/#{folder}?order=title ASC&format=full")

    return unless response.success?

    response.body
  end

  def public_kila_photo_folder?(raw)
    raw['parents'].include?(295) # Assuming '295' is the ID of the parent folder
  end

  def subfolder_ids
    @subfolders ||= get_public_photos_documentgroups&.dig('children', 'documentgroup') || []
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
