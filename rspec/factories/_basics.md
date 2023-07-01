# Basics

### Simple Factory Example

```ruby
# This will guess the User class
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name  { "Doe" }
    admin { false }
  end
end

# This will use the User class (otherwise Admin would have been guessed)
# factory :admin, class: "User"
```

### Best Practices

It is recommended that you have one factory for each class that provides the simplest set of attributes necessary to create an instance of that class. If you're creating ActiveRecord objects, that means that you should only provide attributes that are required through validations and that do not have defaults. Other factories can be created through inheritance to cover common scenarios for each class.

Attempting to define multiple factories with the same name will raise an error.

_[Source](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#best-practices)_

- Prefer `build` over `create`
- Use `sequence` when field must be unique
- Place reusable sequences in a separete file
- Only add fields required to pass validation
- Test the factories
- Specify the class with a string (`factory :admin, class: "User"`)
- Avoid creating a sub-factory for setting trivial attributes
- Prefer dynamic or values over hard-coded
- Use traits to define different versions or subsets of attributes
- Prefer nesting factories over separate files

### Usage

```ruby
# Returns a User instance that's not saved
user = build(:user)

# Returns a saved User instance
user = create(:user)

# Returns a hash of attributes that can be used to build a User instance
attrs = attributes_for(:user)

# Returns an object with all defined attributes stubbed out
stub = build_stubbed(:user)

# Passing a block to any of the methods above will yield the return object
create(:user) do |user|
  user.posts.create(attributes_for(:post))
end
```
