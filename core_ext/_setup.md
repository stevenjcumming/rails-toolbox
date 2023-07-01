# Core Ext

Core Ext is for extend ruby (or rails) core classes like `Date`, `Time`, `String`. These files need to be required in the initializers folder to function properly, because of namespacing.

These files shouldn't be app specific. Basically, you can take these files into any project and they rarely change (except to add more methods).

```ruby
# config/initializers/core_ext.rb
Dir[Rails.root.join('lib/core_ext/**/*.rb')].each { |f| require f }
```

```ruby
# lib/core_ext/date.rb
class Date

  def self.parsable?(string)
    parse(string)
    true
  rescue ArgumentError
    false
  end

end
```

```ruby
# Usage
Date.parsable?("test") # => false
Date.parsable?(1) # => false
Date.parsable?("2022-12-33") # => false
Date.parsable?("2022-12-03") # => true
```
