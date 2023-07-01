# config/initializers/delayed_job
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 30
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

Delayed::Worker.queue_attributes = {
  action_required: { priority: -20 },
  high_priority: { priority: -10 },
  medium_priority: { priority: -1 },
  account_emails: { priority: 0 },
  reminder_emails: { priority: 1 },
  default: { priority: 5 },
  low_priority: { priority: 10 },
  admin_emails: { priority: 15 },
  cache_warming: { priority: 20 },
  reporting: { priority: 25 }  
}
