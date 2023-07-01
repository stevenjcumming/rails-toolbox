class Example < ApplicationRecord

  TIME_FORMAT_REGEX = /\A\d{2}:\d{2}\z/.freeze
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze
  USERNAME_REGEX = /\A[a-zA-Z0-9-_]+\z/i.freeze
  PASSWORD_FORMAT = /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).*\z/
  DATE_FORMATS = %w(american european_standard).freeze
  
end