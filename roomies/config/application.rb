require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Roomies
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Serve uploaded photos and their variants through the app (proxy mode) instead of
    # redirecting to a signed URL that expires after 5 minutes: browsers cache the redirect
    # but not the expiry, so a revisited page could show broken photos.
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # The app operates in Santiago de Chile (see docs/desing-decisions.md)
    config.time_zone = "America/Santiago"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
