class Example < ApplicationRecord

  # Builds an Example instance with unavailable preset
  def self.unavailable_example
    Example.new({ unavailable: true })
    # new({ unavailable: true })
  end


  # Returns an array of color for Example
  # Better looking than Example::COLORS
  COLORS = %w(red orange yellow green blue purple).freeze

  def self.colors
    COLORS
  end


  attribute :token

  def self.find_by_token(token)
    encrypted_token = Digest::SHA256.hexdigest(token)
    Example.find_by(encrypted_token: encrypted_token)
    # find_by(encrypted_token: encrypted_token)
  end

end