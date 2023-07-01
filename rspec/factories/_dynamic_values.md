# Dynamic Values

[Faker](https://github.com/faker-ruby/faker) or [FFaker](https://github.com/ffaker/ffaker) are great options

### Examples

```ruby
name { Faker::Name.name }
description { Faker::Lorem.paragraph }
description { Faker::Lorem.sentence(word_count: 3, random_words_to_add: 4) }
first_name { Faker::Name.first_name }
current_sign_in_ip { Faker::Internet.ip_v4_address }
website { Faker::Internet.url(scheme: "https") }
phone_number { Faker::PhoneNumber.cell_phone }
address { Faker::Address.street_address }
```

### Commonly used Faker generators

- [`Faker::Name.first_name`](https://github.com/faker-ruby/faker/blob/main/doc/default/name.md)
- [`Faker::Name.last_name`](https://github.com/faker-ruby/faker/blob/main/doc/default/name.md)
- [`Faker::Name.name`](https://github.com/faker-ruby/faker/blob/main/doc/default/name.md)
- [`Faker::Internet.email`](https://github.com/faker-ruby/faker/blob/main/doc/default/internet.md)
- [`Faker::Internet.url`](https://github.com/faker-ruby/faker/blob/main/doc/default/internet.md)
- [`Faker::Internet.ip_v4_address`](https://github.com/faker-ruby/faker/blob/main/doc/default/internet.md)
- [`Faker::Internet.password`](https://github.com/faker-ruby/faker/blob/main/doc/default/internet.md)
- [`Faker::Address.city`](https://github.com/faker-ruby/faker/blob/main/doc/default/address.md)
- [`Faker::Address.street_address`](https://github.com/faker-ruby/faker/blob/main/doc/default/address.md)
- [`Faker::Address.country`](https://github.com/faker-ruby/faker/blob/main/doc/default/address.md)
- [`Faker::Lorem.sentence`](https://github.com/faker-ruby/faker/blob/main/doc/default/lorem.md)
- [`Faker::Lorem.paragraph`](https://github.com/faker-ruby/faker/blob/main/doc/default/lorem.md)
- [`Faker::PhoneNumber.phone_number`](https://github.com/faker-ruby/faker/blob/main/doc/default/phone_number.md)
- [`Faker::Date.between`](https://github.com/faker-ruby/faker/blob/main/doc/default/date.md)
- [`Faker::Number.between`](https://github.com/faker-ruby/faker/blob/main/doc/default/number.md)
- [`Faker::Boolean.boolean`](https://github.com/faker-ruby/faker/blob/main/doc/default/boolean.md)
- [`Faker::Company.name`](https://github.com/faker-ruby/faker/blob/main/doc/default/company.md)
- [`Faker::Company.catch_phrase`](https://github.com/faker-ruby/faker/blob/main/doc/default/company.md)
- [`Faker::Games::Pokemon.name`](https://github.com/faker-ruby/faker/blob/main/doc/games/pokemon.md)
- [`Faker::Verb.base`](https://github.com/faker-ruby/faker/blob/main/doc/default/verbs.md)
