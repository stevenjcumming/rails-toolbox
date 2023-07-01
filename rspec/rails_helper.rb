# https://rspec.info/documentation/
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

ENV["RAILS_ENV"] = "test"

abort("The Rails environment is running in production mode!") if Rails.env.production?

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Ignore Mailers during Tests
ActiveJob::Base.queue_adapter = :inline
ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = false
ActiveJob::Base.queue_adapter = Rails.application.config.active_job.queue_adapter

RSpec.configure do |config|
  config.include RequestSpecHelper
  config.include ActiveSupport::Testing::TimeHelpers

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run_excluding broken: true
end
