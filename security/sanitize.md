# Sanitizing

Sanitizing or escaping user inputs is an important layer in security. For more about security in general read my [Rails Security Guide](https://github.com/stevenjcumming/rails-security-guide)

### Sanitize Params

This should be the standard practice in your controllers, and it's the absolute minimum you can do, but it's by no means sufficient.

```ruby
# very bad
Example.update(params)

# good
Example.update(example_params)

def example_params
  params.permit(:param_1, :param_2, :param_3)
end
```

### Sanitize HTML

```ruby
<%= sanitize @user.biography %>
<%= sanitize @comment.body, tags: %w(strong em a), attributes: %w(href) %>
```

Here's an example for sanitizing user input in the controller for HTML that will be displayed. You could sanitize in the model, but I prefer to sanitize in controllers.

```ruby
def sanitized_biography
  sanitizer = Rails::HTML5::SafeListSanitizer.new
  allowed_tags = %w(p)
  allowed_attributes = %w()
  sanitized_biography = sanitizer.sanitize(params[:biography], tags: allowed_tags, attributes: allowed_attributes)
end
```

It's important to note that even the HTML Sanitizer can miss things. For example if you allow `<a>` tags and `href` or `onClick` attributes. You could still be vulnerable to attacks.

```ruby
sanitize("javascript:alert('attack')")
#=> "javascript:alert('attack')"

sanitize("<script>attack();</script>")
# => "attack();"
```

```html
<a href="javascript:alert('attack')">Click me</a>
<a href="#" onclick="alert('attack'); return false;">Click me</a>
```

One way to prevent this is to use a create permit scrubber. An example is in this directory "permit_scrubber.rb"

Read more: [Rails HTML Sanitizers
](https://github.com/rails/rails-html-sanitizer)

### Sanitize URL

Let's say you want to link to a user's instagram profile or personal website. You can sanitize the url in a few ways. The `sanitize` method won't help for URLs, but it's a good idea to use it to remove tags.

1. Don't accept a URL, accept a handle or username. (A little harder to do with YouTube)

```ruby
<%= link_to "Instagram", "https://instagram.com/" + params[:instagram_username] %>
<%= link_to "Instagram", "https://twitter.com/" + params[:twitter_handle] %>
```

2. Sanitize (and/or validate) the url

Sanitize in the controller

```ruby
def sanitized_personal_website
  URI.extract(params[:personal_website], ['http', 'https']).first


  # URI.extract("instagram.com", ['http', 'https'])
  # => []

  # URI.extract("javascript:alert('attack')", ['http', 'https'])
  # => []
end
```

Validate in the model

```ruby
before_validation :sanitize_personal_website
validates :personal_website, url: true # UrlValidator is under /validators
```

### Sanitize SQL

```ruby
# bad
Book.where("title = #{params[:title]}")
Book.where("title LIKE ?", "%#{params[:title]}%")

# good

Book.where(title: params[:title])

Book.where("title LIKE ?", Book.sanitize_sql_like(params[:title]) + "%")

values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first

Model.sanitize_sql(["name=? and group_id=?", "foo'bar", 4])
input = Model.sanitize_sql(params[:input])

```

Adding `.to_i` can help mitigate SQL injections by throwing an error before SQL is executed

```ruby
def set_example
  @example = current_user.examples.find_by_id(params[:id].to_i)
end
```
