# This service retrieves the photos that were uploaded to webling public documents
# the photos are then rendered per folder in the view
# the photos are stored in cloudinary and cached so that the loading is quicker

class WeblingApiService
  require 'faraday'
  BASE_URL = 'https://hildegarten.webling.ch'.freeze

  def initialize
    @api_key = Rails.application.credentials.dig(:webling, :api_key)
  end

  def subfolders_with_photo_ids
    last_fetch_timestamp = Rails.cache.read('last_fetch_timestamp') || Date.yesterday.to_time.to_i
    folder_changes = fetch_changes('documentgroup', last_fetch_timestamp)
    photo_changes  = fetch_changes('document', last_fetch_timestamp)

    if folder_changes.present? || photo_changes.present?
      Rails.logger.info "🔄 Detected Webling changes, refreshing cache..."
      updated_subfolders = fetch_subfolders_with_photo_ids
      cache_subfolders(updated_subfolders)
      updated_subfolders
    else
      Rails.logger.info "✅ Using cached Webling data"
      Rails.cache.fetch('subfolders_with_photo_ids', expires_in: 12.hours) do
        fetch_subfolders_with_photo_ids
      end
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.error "❌ Webling connection error: #{e.message}"
    Rails.cache.fetch('subfolders_with_photo_ids', expires_in: 12.hours) || []
  end

  private

  def fetch_subfolders_with_photo_ids
    subfolder_ids.map { |folder_id| fetch_subfolder_metadata(folder_id) }.compact.sort_by do |f|
      title = f[:title].to_s
      if title =~ /^(\d{4})-(\d{2})/
        year, month = $1.to_i, $2.to_i
        [year, month]
      else
        [0, 0]
      end
    end.reverse
  end

  # ⚡ only load metadata (not full photo files)
  def fetch_subfolder_metadata(folder_id)
    raw = request_photos_per_subfolder(folder_id)
    return unless raw && public_kila_photo_folder?(raw)

    photo_ids = raw.dig('children', 'document')
    folder_title = raw.dig('properties', 'title')
    return unless photo_ids

    {
      id: folder_id,
      title: folder_title,
      # 🧠 Only pass minimal data — controller will enqueue full caching later
      photo_objects: photo_ids.flatten.map { |id| { id: id } }
    }
  end

  def cache_subfolders(subfolders)
    Rails.cache.write('subfolders_with_photo_ids', subfolders, expires_in: 12.hours)
  end

  def fetch_changes(object_type, since_timestamp)
    response = conn.get("/api/1/changes/#{since_timestamp}")
    return [] unless response.success?

    Rails.cache.write('last_fetch_timestamp', Time.now.to_i)
    extract_changed_ids(response.body, object_type)
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.error "⚠️ Failed to fetch #{object_type} changes: #{e.message}"
    []
  end

  def extract_changed_ids(changes_body, object_type)
    return [] unless changes_body['objects'].any?
    changes_body['objects'][object_type] || []
  end

  def subfolder_ids
    data = get_public_photos_documentgroups
    data&.dig('children', 'documentgroup') || []
  end

  def get_public_photos_documentgroups
    response = conn.get('/api/1/documentgroup/295')
    return unless response.success?
    response.body
  end

  def request_photos_per_subfolder(folder)
    response = conn.get("/api/1/documentgroup/#{folder}?order=title ASC&format=full")
    response.success? ? response.body : nil
  end

  def public_kila_photo_folder?(raw)
    raw['parents'].include?(295)
  end

  def conn
    @conn ||= Faraday.new(url: BASE_URL) do |faraday|
      faraday.headers['apikey'] = @api_key
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.options.timeout = 10
      faraday.options.open_timeout = 5
      faraday.adapter Faraday.default_adapter
    end
  end
end

