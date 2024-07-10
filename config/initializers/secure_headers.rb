# configure requests from other domains/websites
# this is needed to allow incorporating a subpage as an iframe into webling
if Rails.env.production?
  SecureHeaders::Configuration.default do |config|
    config.csp = {
      default_src: %w('self'),
      script_src: %w('self'),
      connect_src: %w('self'),
      img_src: %w('self' data:),
      style_src: %w('self' 'unsafe-inline'),
      font_src: %w('self' data:),
      frame_ancestors: %w('self' https://hildegarten.webling.eu),
      form_action: %w('self'),
      base_uri: %w('self'),
      frame_src: %w('self' https://hildegarten.webling.eu)
    }
  end
else
  SecureHeaders::Configuration.default do |config|
    config.csp = {
      default_src: %w('self'),
      script_src: %w('self' 'unsafe-inline' 'unsafe-eval'),
      connect_src: %w('self'),
      img_src: %w('self' data:),
      style_src: %w('self' 'unsafe-inline'),
      font_src: %w('self' data:),
      frame_ancestors: %w('self' https://hildegarten.webling.eu),
      form_action: %w('self'),
      base_uri: %w('self'),
      frame_src: %w('self' https://hildegarten.webling.eu)
    }
  end
end
