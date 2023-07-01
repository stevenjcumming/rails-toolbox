# Formatting Keys

If for some reason you need to transform the keys to camel case you can use this

```ruby
# config/environment.rb

Jbuilder.key_format camelize: :lower
Jbuilder.deep_format_keys true

```

If you are also rendering json elsewhere like for example, you'll have to look for alternative solutions.

```ruby
render json: sample_response.to_json, status: :ok
```

One very ugly (but effective) way to do this for one-off situations is:

```ruby
sample_response.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
```
