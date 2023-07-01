class ApplicationForm

  include ActiveModel::Model
  include ActiveModel::Validations
  include ActionController::StrongParameters

  attr_reader :current_user, :params

  def initialize(params, current_user=nil)
    @current_user = current_user
    @params = ActionController::Parameters.new(params).permit!
    super(@params)
  end

  private

    def collect_errors(*records)
      records.each do |record|
        next if !record.respond_to?(:errors) || record.errors.blank?

        add_errors_for(record.errors, record.class.name)
      end
    end

    def add_errors_for(model_errors, _model)
      model_errors.each do |error|
        record = _model.downcase
        attribute = attribute_for_error(error.attribute)
        code = "#{_model.titleize.gsub(/\W/, '_').underscore}_failed"
        message = "#{_model} #{error.attribute} #{error.message}"

        errors.add(attribute, error.type, code: code, message: message)
      end
    end

    def attribute_for_error(attribute)
      instance_names = instance_variables
      method_names = self.class.instance_methods(false).map(&:to_s)
      filtered_method_names = method_names.select! { |a| a.include?("=") }
      attributes = instance_names + filtered_method_names.map { |a| a.sub("=", "") }
      attributes.include?(attribute.to_s) ? attribute.to_sym : :base
    end

end
