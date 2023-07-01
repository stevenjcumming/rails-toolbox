class Example < ApplicationRecord

  # https://guides.rubyonrails.org/active_record_callbacks.html#available-callbacks

  before_validation :set_reference_id, on: :create
  before_validation :downcase_email
  before_save :archive_product_question_options, if: :will_save_change_to_archived_at?
  after_create :set_preferences
  after_save :adjust_ranking_score
  before_validation :set_default_attributes, on: :create

  private 

    def set_reference_id
      self.reference_id = loop do
        ref_id = SecureRandom.hex
        break ref_id unless self.class.exists?(reference_id: ref_id)
      end
    end

    def downcase_email
      email&.downcase!
    end

    def set_default_attributes
      self.name ||= ""
      self.username ||= UsernameGenerator.generate
      self.description ||= ""
      self.time_zone ||= "America/New_York"
      self.date_format ||= "american"
      self.time_format ||= "12h"
    end

end