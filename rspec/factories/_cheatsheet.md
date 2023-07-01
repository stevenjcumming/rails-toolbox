# Usage

This is just the commonly used and important stuff. For more information go to [the factory_bot book](https://thoughtbot.github.io/factory_bot)

### section

```ruby

```

### Alias

```ruby
factory :user, aliases: [:author, :commenter] do; end
```

### Dependent attributes

```ruby
factory :user do
  first_name { "Joe" }
  last_name  { "Blow" }
  email { "#{first_name}.#{last_name}@example.com".downcase }
end
```

### Nested factories

```ruby
factory :post do
  title { "A title" }

  factory :approved_post do
    approved { true }
  end
end
```

### Associations

```ruby

factory :post do
  # ...
  author
end

# or

factory :post do
  # ...
  association :author
end

```

### has_many

```ruby
FactoryBot.define do
  factory :post do
    title { "Through the Looking Glass" }
    user
  end

  factory :user do
    name { "Adiza Kumato" }

    factory :user_with_posts do
      transient do
        posts_count { 5 }
      end

      posts do
        Array.new(posts_count) { association(:post) }
      end
    end
  end
end

create(:user_with_posts).posts.length # 5
create(:user_with_posts, posts_count: 15).posts.length # 15
build(:user_with_posts, posts_count: 15).posts.length # 15
build_stubbed(:user_with_posts, posts_count: 15).posts.length # 15
```

### Polymorphic associations

```ruby
FactoryBot.define do
  factory :video
  factory :photo

  factory :comment do
    for_photo # default to the :for_photo trait if none is specified

    trait :for_video do
      association :commentable, factory: :video
    end

    trait :for_photo do
      association :commentable, factory: :photo
    end
  end
end

create(:comment)
create(:comment, :for_video)
create(:comment, :for_photo)
```

### Interconnected associations

```ruby

class Student < ApplicationRecord
  belongs_to :school
  has_one :profile
end

class Profile < ApplicationRecord
  belongs_to :school
  belongs_to :student
end

class School < ApplicationRecord
  has_many :students
  has_many :profiles
end

FactoryBot.define do
  factory :student do
    school
    profile { association :profile, student: instance, school: school }
  end

  factory :profile do
    school
    student { association :student, profile: instance, school: school }
  end

  factory :school
end
```

### Sequences

```ruby
factory :user do
  sequence(:email) { |n| "person#{n}@example.com" }
  sequence :priority, %i[low medium high urgent].cycle
  sequence(:email, aliases: [:sender, :receiver]) { |n| "person#{n}@example.com" }
end
```

### Traits

```ruby
# creates an admin user with :active status and name "Jon Snow"
# create(:user, :admin, :active, name: "Jon Snow")
factory :user do
  name { "Friendly User" }

  trait :active do
    name { "John Doe" }
    status { :active }
  end

  trait :admin do
    admin { true }
  end
end

# with nested factories
factory :story do
  title { "My awesome story" }
  author

  trait :published do
    published { true }
  end

  trait :unpublished do
    published { false }
  end

  trait :week_long_publishing do
    start_at { 1.week.ago }
    end_at { Time.now }
  end

  trait :month_long_publishing do
    start_at { 1.month.ago }
    end_at { Time.now }
  end

  factory :week_long_published_story,    traits: [:published, :week_long_publishing]
  factory :month_long_published_story,   traits: [:published, :month_long_publishing]
  factory :week_long_unpublished_story,  traits: [:unpublished, :week_long_publishing]
  factory :month_long_unpublished_story, traits: [:unpublished, :month_long_publishing]
end
```

### Enums

```ruby
class Task < ActiveRecord::Base
  enum status: {queued: 0, started: 1, finished: 2}
end
```

```ruby
# factory_bot will automatically define traits for each possible value of the enum
FactoryBot.define do
  factory :task
end

FactoryBot.build(:task, :queued)
FactoryBot.build(:task, :started)
FactoryBot.build(:task, :finished)
```

### Callbacks

factory_bot makes available four callbacks for injecting some code:

`after(:build)` - called after a factory is built (via FactoryBot.build, FactoryBot.create)
`before(:create)`- called before a factory is saved (via FactoryBot.create)
`after(:create)` - called after a factory is saved (via FactoryBot.create)
`after(:stub)` - called after a factory is stubbed (via FactoryBot.build_stubbed)

### Lists

```ruby
built_users   = build_list(:user, 25)
created_users = create_list(:user, 25)
stubbed_users = build_stubbed_list(:user, 25) # array of stubbed users

twenty_somethings = build_list(:user, 10) do |user, i|
  user.date_of_birth = (20 + i).years.ago
end

twenty_somethings = create_list(:user, 10) do |user, i|
  user.date_of_birth = (20 + i).years.ago
  user.save!
end
```
