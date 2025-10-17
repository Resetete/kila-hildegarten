class WeblingPhotoCacheJob < ApplicationJob
  queue_as :default

  def perform(photo_id)
    WeblingPhotoCacheService.new(photo_id: photo_id).fetch_or_store!
  end
end
