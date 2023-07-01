```ruby
class Example < ApplicationRecord

  # Mixins
  include Exampleable

  # Constants

  MY_CONSTANT = 'some value'.freeze

  # Attributes

  attr_accessor :example

  # Validations

  validates :name, presence: true

  # Associations

  has_many :posts
  belongs_to :account

  # Macros

  has_secure_password
  enum status: { active: 0, inactive: 1, archived: 2 }
  store_accessor :user_attributes, :color
  delegate :user, to: :product

  # Scopes

  scope :admin, -> { where(admin: true) }
  pg_search_scope :search_by_title, against: :title

  # Callbacks

  before_validation :downcase_email

  # Class Methods

  def self.public_class_method

  end

 # or

  class << self
    def public_class_method

    end

    private
  end

  # Instance Methods

  def public_instance_method

  end

  private

end
```
