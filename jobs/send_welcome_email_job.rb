class SendWelcomeEmailJob < ApplicationJob

  queue_as :account_emails

  def perform(user_id)
    user = User.find_by!(id: user_id)
    UserMailer.send_welcome_email(user).deliver_now
  end

end

# Usage
# SendWelcomeEmailJob.perform_now(user.id)
# SendWelcomeEmailJob.perform_later(user.id)
# SendWelcomeEmailJob.set(wait_until: Time.current + 24.hour).perform_later(user.id)
# SendWelcomeEmailJob.set(wait: 2.hours).perform_later(user.id)