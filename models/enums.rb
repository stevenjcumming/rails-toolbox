class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveRecord/Enum.html
  
  STATUSES = %w(pending settled available outstanding paid)

  enum status: STATUSES.zip(STATUSES).to_h
  enum :category, { free: 0, premium: 1 }, suffix: true, default: :free
  enum :status, [ :draft, :published, :archived ], prefix: true, scopes: false

end
