# https://github.com/rails/rails-html-sanitizer
# lib/scrubbers/biography_scrubber.rb
class BiographyScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w[a p div] # + additional tags from params
  end

  def allowed_attributes
    super + %w[href]
  end

  def skip_node?(node)
    return false unless node.name == "a" && node["href"]
    !node["href"].start_with?("https://", "http://")
  end
end

# Usage
def sanitized_biography
  sanitizer = Rails::HTML5::SafeListSanitizer.new
  scrubber = BiographyScrubber.new
  sanitizer.sanitize(params[:biography], scrubber: scrubber)
end