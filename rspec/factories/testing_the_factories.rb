# The old way
# spec/factories_spec.rb
require "rails_helper"

FactoryBot.factories.each do |factory|
  describe "#{factory.name} factory" do
    it "is valid when built" do
      expect { build(factory.name) }.to be_valid
    end
  end
end

# The new way
# make sure you have Database Cleaner
# lib/tasks/factory_bot.rake
namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    if Rails.env.test?
      DatabaseCleaner.cleaning do
        FactoryBot.lint traits: true
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end
end