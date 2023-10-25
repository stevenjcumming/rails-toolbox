# Policies

Policies define authorization rules for accessing resources. This is done for a user directly or with roles, permissions, or teams. You can implement this yourself, or use the [Pundit](https://github.com/varvet/pundit) gem. This section is not intended to be a guide to Pundit. It's an example implementation in context of our controllers, forms, etc. It also assumes a user has an enum called `role` and the values are `"admin"` or `"member"`.

### Setup

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError unless user
    @user = user
    @record = record
  end

  # all actions are denied by default
  %i[index? show? create? update? destroy?].each do |action|
    define_method(action) { false }
  end

  def admin?
    user.admin? # Assuming `admin` is the attribute that designates an admin
  end

  # this isn't going to work if associations (or delegation) aren't properly configured
  # for example if you use post.author and post.author_id
  def belongs_to_user?
    record.user_id == user.id
  end

  class Scope
    def initialize(user, scope)
      raise Pundit::NotAuthorizedError unless user
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :use, :scope
  end
end
```

```ruby
# app/policies/example_policy
class ExamplePolicy < ApplicationPolicy

  def create
    admin? || belongs_to_user?
  end

  def update?
    admin? || belongs_to_user?
  end

  def destroy?
    admin?
  end

  # @example.update(permitted_attributes(@example))
  def permitted_attributes
    if admin?
      [:attribute_1, :attribute_2, :attribute_3]
    else
      [:attribute_2]
    end
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

end
```

### Implementation

Option 1: In the controller (preferred)

```ruby
def index
  # This can obviously be moved with a before_action
  @example = policy_scope(Example)
end

def show
  authorize @example
end

def create
  authorize Example
  example_form = ExampleForm.new(example_params, current_user)
  if example_form.save
    @example = example_form.example
  else
    errors = example_form.errors
    render json: { errors: errors }, status: :bad_request
  end
end

def update
  authorize @example
  example_form = ExampleForm.new(example_params.merge(example: @example), current_user)
  if example_form.save
    @example = example_form.example
  else
    errors = example_form.errors
    render json: { errors: errors }, status: :bad_request
  end
end

def destroy
  authorize @example
  if @example.destroy
    head :ok
  else
    errors = @example.errors
    render json: { errors: errors }, status: :bad_request
  end
end

private

  def set_example
    @example = policy_scope(Example).find_by_id(params[:id].to_i)
  end
```

Option 2: In the form

```ruby

class ExampleForm < ApplicationForm
  include Pundit::Authorization

  def save
    authorize example
    # omit transaction & rescue
  end

  def example
    @example ||= Example.new(user: current_user)
  end
end
```
In a form we can alternatively use the policies directly

```ruby
validate :authorization_example

# omit

private

  def authorization_example
    unless ExamplePolicy.new(current_user, @example).update? # or create?
      errors.add(:base, "You are not authorized to perform this action.")
      return false
    end
  end
```

### Permissions-based

We could also use permissions, but adding a permissions attribute to `ApplicationPolicy`

```ruby
attr_reader :permissions ...

def initialize(user, record)
  @permissions = user.permissions
  ...
end
```

Then use it in the policies like this

```ruby
def update?
  permissions.can_update_things? && record.user == user
end
```

### Side Note

If the same user has different roles for different accounts or teams, you can add a Context to the pundit user.

```ruby
# app/models/user_context.rb
class UserContext
  attr_reader :user, :account, :role

  def initialize(user, account)
    @user    = user
    @account = account
    @role    = user.role_for(account)
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def pundit_user
    UserContext.new(current_user, current_account)
  end
end

# app/policies/application_policy.rb

def initialize(context, record)
  @user = context.user
  @account = context.account
  @role = context.role
  @record = record
end
```

