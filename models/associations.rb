class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html

  belongs_to :user 
  belongs_to :user, touch: true
  belongs_to :purchaseable, polymorphic: true, touch: true
  belongs_to :author, class_name: "User" # author_id
  belongs_to :topic, optional: true
  belongs_to :manager, class_name: "Employee", optional: true

  # add `index: { unique: true }` to the associated models migration file
  # to ensure another record isn't associated with this model
  # creating an accidental one-to-many relationship
  has_one :last_message, -> { not_deleted.order(created_at: :desc) }, class_name: "Message"
  has_one :cancelation, as: :cancelable
  has_one :product_search, dependent: :destroy

  has_many :interactions
  has_many :groups, through: :memberships
  has_many :topics, dependent: :destroy
  has_many :pictures, as: :imageable
  has_many :products_tags, dependent: :destroy, inverse_of: :product
  has_many :books, -> { where(published: true) }
  has_many :books, -> { published } # Book.published
  has_many :products, -> { distinct }, through: :products_tags
  has_many :producers, -> { distinct }, through: :products, source: :user
  has_many :favoritings, class_name: "Favorite", foreign_key: "favoriter_id" # user's favorites  
  has_many :favorites, class_name: "Favorite", foreign_key: "favoritee_id" # other users favorites of user 
  has_many :favoriters, through: :favorites, source: :favoriter # the other users that favorited the user
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback" # polymorphic Format => Paperback & Hardcover

  accepts_nested_attributes_for :user_preference # has_one
  accepts_nested_attributes_for :prices, allow_destroy: true # has_many
  accepts_nested_attributes_for :avatar, update_only: true
  accepts_nested_attributes_for :avatar, reject_if: :all_blank
  accepts_nested_attributes_for :posts, reject_if: proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :posts, reject_if: :new_record?

  # self join example 
  # t.references :manager, foreign_key: { to_table: :employees }
  
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true 


end