# Auto Loading

Starting with Rails 6, Rails ships with a new and better way to autoload, which delegates to the Zeitwerk gem. We have an initializer for `core_ext` so we don't want to autoload it in `config/application.rb`. We also don't want to autoload assets, generators, etc.

```ruby
# Rails < 7.1
# config/application.rb
config.autoload_paths << "#{Rails.root}/lib"
config.eager_load_paths << "#{Rails.root}/lib"

%w(assets core_ext generators middleware tasks templates).each do |subdir|
  Rails.autoloaders.main.ignore("#{Rails.root}/lib/#{subdir}")
end
```

```ruby
# Rails 7.1+
# config/application.rb
config.autoload_lib(ignore: %w(assets core_ext tasks generators templates))

```
