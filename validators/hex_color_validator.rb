class HexColorValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value.match?(/\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/)
    
    record.errors.add(attribute, options[:message] || "is not a valid hex color")
  end
end