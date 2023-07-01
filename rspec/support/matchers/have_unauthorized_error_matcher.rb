RSpec::Matchers.define :have_unauthorized_error do
  match do |errors|
    errors.any? { |error| error['code'] == 'not_authorized' }
  end

  failure_message do |errors|
    "expected errors to include an unauthorized error, but no such error was found"
  end

  failure_message_when_negated do |errors|
    "expected errors not to include an unauthorized error, but an unauthorized error was found"
  end
end
