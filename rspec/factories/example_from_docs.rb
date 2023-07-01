# Example from the wiki
# https://github.com/thoughtbot/factory_bot/wiki/Example-factories.rb-file
FactoryBot.define do
  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:count)

  factory :user do
    name { "Regular Doe" }

    trait(:young) { dob { 5.days.ago } }
    trait(:adult) { dob { 26.years.ago } }
    trait(:admin)  { admin { true } }
  end

  factory :article do
    sequence(:title) { |n| "Title #{n}" }
    comments_allowed { false }

    factory :unpublished_article do
      published { false }
    end

    factory :article_with_comments do
      transient do
        comments_count { 1 }
      end

      after(:create) do |article, evaluator|
        FactoryBot.create_list(:comment, evaluator.comments_count, article: article)
      end
    end
  end

  factory :page do
    sequence(:title) { |n| "Page #{n}" }
    body             { "Hello, world!" }
  end

  factory :comment do
    article
    email
    body { "This is a brilliant post!" }
    full_name { "Commenter Bob" }
  end
end