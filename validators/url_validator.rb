class UrlValidator < ActiveModel::EachValidator

  RESERVED_OPTIONS = %i[schemes no_local].freeze

  def initialize(options)
    options.reverse_merge!(schemes: %w[http https])
    options.reverse_merge!(message: :url)
    options.reverse_merge!(no_local: true)
    options.reverse_merge!(public_suffix: true)

    super(options)
  end

  def validate_each(record, attribute, value)
    schemes = [*options.fetch(:schemes)].map(&:to_s)
    begin
      uri = Addressable::URI.parse(value)
      host = uri && uri.host
      scheme = uri && uri.scheme

      valid_raw_url = scheme && value =~ /\A#{URI::DEFAULT_PARSER.make_regexp([scheme])}\z/
      valid_scheme = host && scheme && schemes.include?(scheme)
      valid_no_local = !options.fetch(:no_local) || (host && host.include?("."))
      valid_suffix = !options.fetch(:public_suffix) || (host && PublicSuffix.valid?(host, default_rule: nil))

      unless valid_raw_url && valid_scheme && valid_no_local && valid_suffix
        record.errors.add(attribute, :invalid, "#{value} is not a valid URL")
      end
    rescue Addressable::URI::InvalidURIError => e
      record.errors.add(attribute, :invalid, e.message)
    end
  end

end
