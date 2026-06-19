# config/application.rb
require_relative 'boot'
require "logger"
require "active_support/core_ext/numeric/time"
require 'rails/all'

Bundler.require(*Rails.groups)

module KilaHildegarten
  class Application < Rails::Application
    config.load_defaults 6.0

    config.assets.initialize_on_precompile = false
    config.assets.check_precompiled_asset = false

    require_relative '../lib/middleware/cloudflare'
    config.middleware.use Cloudflare

    # Setting the secure headers manually to avoid issues with the secure_headers gem
    # mangling URLs (stripping https://). This is the stable, low-maintenance approach.
    config.action_dispatch.default_headers.merge!(
      'X-Frame-Options'         => 'ALLOWFROM https://hildegarten.webling.eu',
      'Content-Security-Policy' => [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline'",
        "connect-src 'self'",
        "img-src 'self' data: blob: https://*.dropboxusercontent.com https://res.cloudinary.com",
        "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
        "font-src 'self' data: https://fonts.gstatic.com",
        "frame-ancestors 'self' https://hildegarten.webling.eu",
        "form-action 'self'",
        "base-uri 'self'",
        "frame-src 'self' https://hildegarten.webling.eu https://hildegarten.webling.ch https://www.openstreetmap.org"
      ].join('; ')
    )
  end
end
