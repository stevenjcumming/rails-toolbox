class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html#method-i-attribute
  
  attribute :price_in_cents, :integer
  attribute :price_in_cents, :money # see "Creating Custom Types" in docs ^ 
  attribute :my_default_proc, :datetime, default: -> { Time.now } 
  attribute :small_int, :integer, limit: 2
  attribute :my_string, :string
  
  attr_readonly :reference_id

end