RSpec::Matchers.define :have_validation_error do
  match do |errors|
    # Can't use errors.any? itself, because it would match unauthorized or login error
    errors.any? { |error| error['validation'] }
  end

  failure_message do |errors|
    "expected errors to include an error, but no such error was found"
  end

  failure_message_when_negated do |errors|
    "expected errors not to include an error, but an error was found"
  end
end
