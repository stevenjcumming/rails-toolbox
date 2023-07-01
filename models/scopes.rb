class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope

  scope :active, -> { where(active: true) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :show_in_search, -> { joins(:user_preference).where(user_preference: { show_in_search: true }) }
  scope :upcoming, -> (date_time) { where(event_at: date_time..).order(exception_on: :asc) }
  scope :action_required, -> { where(status: ['unconfirmed', 'closed']) }
  scope :dry_clean_only, -> { joins(:washing_instructions).where('washing_instructions.dry_clean_only = ?', true) }


end