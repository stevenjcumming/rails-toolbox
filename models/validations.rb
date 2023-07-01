class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html

  validates :name, presence: true
  validates :published, inclusion: { in: [true, false] }
  validates :country_code, inclusion: { in: COUNTRY_CODES }, allow_nil: true
  validates :email, 
            presence: true, 
            length: { in: 6..64 }, 
            uniqueness: { case_sensitive: false },
            format: { with: EMAIL_REGEX }
  validates :content, length: { maximum: 500 }
  validates :instagram, url: true # ActiveModel::EachValidator
  validates :scheduled_on, date: { only_today_and_future: true } # ActiveModel::EachValidator
  validates :end_time, :start_time, presence: true
  validates :amount, numericality: { greater_than: 0, less_than: 0.5 }
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: [:manager_id, :company_id] }
  validates :user_id, uniqueness: { scope: :connection_id }



  validate :validate_days_of_week
  validates_with RefundValidator # ActiveModel::Validator

  private 

    def validate_days_of_week
      errors.add(:by_week_day, :invalid) unless Date::DAYNAMES.include?(by_week_day)
    end

end