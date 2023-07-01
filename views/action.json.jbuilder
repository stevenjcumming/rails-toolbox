# index.json.jbuilder
json.cache! ["v1", 'users', @users.map(&:id), @users.maximum(:updated_at).to_i] do
  json.users @users, partial: "user", as: :user, cached: true
end

# show.json.jbuilder
json.partial! "user", user: @user

# create.json.builder
json.partial! "user", user: @user

# update.json.jbuilder
json.partial! "user", user: @user

# _user.json.jbuilder
json.cache! ["v1", user] do
  json.extract! user, :name, :email, :location
  json.comments user.comments, partial: "api/v1/comments/comment", as: :comment, cached: true
  json.attachments user.attachments, partial: "api/v1/attachments/attachment", as: :attachment, cached: true
end
