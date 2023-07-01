# for this example assume the model is user
# views/api/v1/users/_user.json.jbuilder

# it's a good security practice not to show the real id
json.id json.reference_id

# basic collection with a partial from a different folder
json.comments user.comments, partial: "api/v1/comments/comment", as: :comment, cached: true

# partial for commonly used content, that doesn't have a directory of it's own
# there's no need to do this if api/v1/photos/photo exists  
# See template_inheritance.md for more information
json.photos user.photos, partial: "api/v1/shared/photo", as: :photo, cached: true

# use methods from helper
json.content format_content(@message.content)

# prefer "extract"
json.extract! @post, :id, :title, :content, :published_at

# set empty collections to []
if @user.photos.exists?
  json.photos user.photos, partial: "api/v1/photos/photo", as: :photo, cached: true
else
  json.photos []
end

# set empty collection 
json.photos do
  if @user.photos.exists?
    json.array! user.photos do |photo|
      json.extract! @photo, :id,
    end
  else
    []
  end
end

# Don't ignore null value 
json.ignore_nil! # bad

# skip in array
json.array! @users do |user|
  next if user.anonymous?

  json.id user.id
end

