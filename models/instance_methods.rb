class Example < ApplicationRecord

  def archived?
    !!archived_at
  end

  def expired?
    Time.current > (updated_at + 10.minutes)
  end

  # used for the double checks in a group chat
  def read?
    message_recipients.pluck(:read).any?
  end

  def profit
    revenue - expenses
  end

  def fee_rate
    if special_promo && Time.current <= special_promo_expired_at
      special_promo.rate
    elsif free_trial
      0
    else 
      usual_rate
    end
  end

  # Rails.cache.write([user, :online], true) is somwhere else
  def online?
    return false unless user_preference&.show_online?
    Rails.cache.fetch([self, :online], expires_in: 30.minutes) do
      false
    end
  end

end
