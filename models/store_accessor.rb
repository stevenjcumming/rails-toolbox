class Example < ApplicationRecord

  # https://api.rubyonrails.org/classes/ActiveRecord/Store.html

  # If not using structured database data types (e.g text)
  store :settings, accessors: [ :color, :homepage ], coder: JSON
  store :parent, accessors: [ :name ], coder: JSON, prefix: true
  store :spouse, accessors: [ :name ], coder: JSON, prefix: :partner
  store :settings, accessors: [ :two_factor_auth ], suffix: true
  store :settings, accessors: [ :login_retry ], suffix: :config

  # If you are using structured database data types 
  # (e.g. PostgreSQL hstore/json, or MySQL 5.7+ json
  store_accessor :column_a, :accessor_one, :accessors_two
  store_accessor :column_a, :accessor_three, prefix: true

  # OverOverwriting default accessors
  store :settings, accessors: [:volume_adjustment]

  def volume_adjustment=(decibels)
    super(decibels.to_i)
  end

  def volume_adjustment
    super.to_i
  end

end