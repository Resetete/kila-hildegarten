source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'devise'
gem 'carrierwave-dropbox', '~> 2.0'
gem 'mini_magick', '~> 4.11'
# support videos
gem 'streamio-ffmpeg'
# check file types
gem 'marcel'

gem 'pg'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
# allow fonte awesome 5 icons
gem 'font_awesome5_rails'
# compatibility of ruby 2 to r3 upgrade
gem 'psych', '< 4'

gem 'net-ftp', require: false
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

gem 'haml'

# requests
gem 'faraday'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# cpontrol page security, e.g. incorporating webpages as iframe
gem 'secure_headers'

group :production do
  # use postgres for all environments
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  #gem 'factory_bot_rails'
  # Use sqlite3 as the database for Active Record
  #gem 'sqlite3', '~> 1.4'
  gem 'rspec-rails', '~> 3.4'

  # Basic Pry Setup
  gem 'awesome_print' # pretty print ruby objects
  gem 'pry' # Console with powerful introspection capabilities
  gem 'pry-byebug' # Integrates pry with byebug
  gem 'pry-doc' # Provide MRI Core documentation
  gem 'pry-rails'
  # Auxiliary Gems
  gem 'pry-rescue' # Start a pry session whenever something goes wrong
  gem 'pry-theme' # An easy way to customize Pry colors via theme files
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 3.0', require: false
  gem 'database_cleaner', '~> 1.5'
  gem 'faker', '~> 1.6.1'
  gem 'factory_girl_rails', '~> 4.5.0', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
