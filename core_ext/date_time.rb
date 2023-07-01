class DateTime

  def self.parsable?(string)
    parse(string)
    true
  rescue ArgumentError
    false
  end

end