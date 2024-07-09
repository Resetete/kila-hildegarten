SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: %w('self'),
    frame_ancestors: %w('self') # Default policy
  }
end
