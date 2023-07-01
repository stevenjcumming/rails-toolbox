# Queries

Big list of finder methods (and ActiveRecord::Relation)

- [`annotate`][]
- [`find`][]
- [`create_with`][]
- [`distinct`][]
- [`eager_load`][]
- [`extending`][]
- [`extract_associated`][]
- [`from`][]
- [`group`][]
- [`having`][]
- [`includes`][]
- [`joins`][]
- [`left_outer_joins`][]
- [`limit`][]
- [`lock`][]
- [`none`][]
- [`offset`][]
- [`optimizer_hints`][]
- [`order`][]
- [`preload`][]
- [`readonly`][]
- [`references`][]
- [`reorder`][]
- [`reselect`][]
- [`regroup`][]
- [`reverse_order`][]
- [`select`][]
- [`where`][]
- [`ActiveRecord::Relation`][]

[`ActiveRecord::Relation`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`annotate`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate
[`create_with`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-create_with
[`distinct`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`extending`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extending
[`extract_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extract_associated
[`find`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`from`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
[`group`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`optimizer_hints`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-optimizer_hints
[`order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where

### Conditions

String conditions

```ruby
Book.where("title LIKE ?", params[:title] + "%")
```

Hash conditions

```ruby
Book.where(out_of_print: true)
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
Book.where(created_at: (Time.now.midnight - 1.day)..) # endless
Customer.where(orders_count: [1,3,5])
```

Not condition

```ruby
Customer.where.not(country: "UK")
Customer.where.not(country: nil)
```

Or condition

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1,3,5]))
```

And condition

```ruby
Customer.where(last_name: 'Smith').where(orders_count: [1,3,5]))
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

### Ordering

```ruby
Book.order(created_at: :desc)
Book.order(created_at: :asc)
Book.order(title: :asc, created_at: :desc)
Book.order(:title, created_at: :desc)
```

### Group

```ruby
User.group(:name)
# SELECT "users".* FROM "users" GROUP BY name
# => [#<User id: 3, name: "Foo", ...>, #<User id: 2, name: "Oscar", ...>]

User.select([:id, :first_name]).group(:id, :first_name).first(3)
# => [#<User id: 1, first_name: "Bill">, #<User id: 2, first_name: "Earl">, #<User id: 3, first_name: "Beto">]

Order.group(:status).count
# => {"being_packed"=>7, "shipped"=>12}
Person.group(:last_name).average(:birth_date)
```

### Having

Note that you can't use HAVING without also specifying a GROUP clause.

```ruby
Order.having('SUM(price) > 30').group('user_id')
Order.select("created_at, sum(total) as total_price").group("created_at").having("sum(total) > ?", 200)
```

### Joins

```ruby
# basic join
articles = Article.includes(:comments)

# multiple joins
users = User.joins(:posts, :account)

# nested join
articles = Article.includes(comments: [:author])
books = Book.joins(reviews: :customer)

# multilevel nested join
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier] )

# conditioned join
articles = Article.joins(:comments).where(comments: { author_id: author_id }).distinct
User.joins(:posts).where("posts.created_at < ?", Time.now)
User.joins(:posts).where("posts.published" => true)
User.joins(:posts).where(posts: { published: true })

# This will find all customers who have orders that were created yesterday,
# using a BETWEEN SQL expression to compare created_at.
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct

# Comment count for articles (with at least one comment)
Article.joins(:comments).group(:id).count("comments.id")

# Comment count for article
Article.left_joins(:comments).group(:id).count("comments.id")

# Articles with more than one post
Article.joins(:comments).group(:id).having("count(comments.id) > 1")
```
