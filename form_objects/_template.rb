class ExampleForm < ApplicationForm

  attr_accessor :param_1,
                :param_2,
                :param_3

  delegate :id, :persisted?, to: :example

  # Additional Validations
  # For example, validate order/product wasn't already refunded 
  # validates_with RefundValidator
  # validate :validate_product_active_not_archived

  def self.model_name
    ActiveModel::Name.new(self, nil, "Example")
  end

  def save
    validate!
    ActiveRecord::Base.transaction do
      example.update(example_params)
      # do other things such as send an email
      # or update another model
      # raise custom errors 
      true
    end
  rescue ActiveRecord::RecordInvalid, ActiveModel::ValidationError => e
    puts e.class
    puts e.message
    # collect_errors(example)
    false
  end

  def example
    @example ||= Example.new(user: current_user)
    # @example ||= current_user.examples.new
  end

  private

    # if you already permitted in the controller 
    # you can use params directly
    def example_params
      params.permit(:param_1, :param_2, :param_2)
    end

    def validate_product_active_not_archived    
      unless !product.archived?
        errors.add(:base, { code: :product_active_not_archived  })
        raise ActiveRecord::RecordInvalid
      end
    end

end
