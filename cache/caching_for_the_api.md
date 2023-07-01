# Caching for the API

Go to the Caching section of my [Rails Performance Guide](https://github.com/stevenjcumming/rails-performance-guide#caching)

Here's a snippet for russian doll caching with Jbuilder

```ruby
# views/api/v1/users/index.json.jbuilder
json.cache! ["v1", 'users', @users.map(&:id), @users.maximum(:updated_at).to_i] do
  json.users @users, partial: "user", as: :user, cached: true
end


# views/api/v1/users/_user.json.jbuilder
json.cache! ["v1", user] do
  json.extract! user, :name, :email, :location
  json.comments user.comments, partial: "api/v1/comments/comment", as: :comment, cached: true
  json.attachments user.attachments, partial: "api/v1/attachments/attachment", as: :attachment, cached: true
end
```
