class DateValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    only_today_and_future = options.fetch(:only_today_and_future, false)
    record.errors.add attribute, "must be a valid date" unless value && Date.parsable?(value.to_s)

    # ensure time zones are the same for comparison
    if only_today_and_future
      today = Date.current
      date = Date.parse(value.to_s)
      unless date >= today
        record.errors.add attribute, "must be a future date or today"
      end
    end

  end
end

