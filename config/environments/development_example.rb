LinkedDevelopmentPmd::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end


PublishMyData.configure do |config|
  #config.sparql_endpoint = 'http://localhost:3030/linkeddev-dev/sparql'
  config.sparql_endpoint = 'http://localhost:9877/linkeddev/sparql'
  config.local_domain = 'linked-development.org'

  config.tripod_cache_store =  nil
  config.sparql_timeout_seconds = 25
  config.response_limit_bytes = 5.megabytes
  config.application_name = "Linked Development"

  # e.g memcached -m 1024 -p 11214 -I 5M -u memcache -l 127.0.0.1
  config.tripod_cache_store  = nil #Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
end

PublishMyDataEnterprise.configure do |c|
  c.aws_access_key_id = 'PUT YOUR KEY HERE'
  c.aws_secret_access_key = 'PUT YOUR SECRET KEY HERE'
  c.downloads_s3_bucket = 'linkeddev-dumps'
end

Tripod.configure do |config|
  config.update_endpoint = 'http://127.0.0.1:3030/linkeddev-dev/update'
  config.data_endpoint = 'http://127.0.0.1:3030/linkeddev-dev/data'
end
