# Warped::Controllers::Filterable

The `Filterable` concern provides a method to filter the records in a controller's action.
The method `filterable_by` is used to define the filterable fields and the filter method to use.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by :name, :email, :created_at

  def index
    users = filter(User.all)
    render json: users
  end
end
```
The `filter` method will use the query parameters to filter the records. For example, to filter the users by name, email, and created_at, the following query parameters can be used:

```
GET /users?name=John
GET /users?email=john@example.com
GET /users?created_at=2021-01-01
```

## Adding type-safety to the fields

The `filterable_by` method, accepts keyword arguments to be passed. The keyword arguments are the field names and the type to cast the query parameter to. This is useful to prevent invalid queries from being executed on the database.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by name: { kind: :string }, email: { kind: :string }, created_at: { kind: :date }

  def index
    users = filter(User.all)
    render json: users
  end
end
```

When passing a value to the query parameter, the value will be cast to the specified type. If casting fails, the query parameter will be ignored.

If the strict flag is passed to the filterable_by method, then it will raise a `Filter::ValueError`.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by created_at: { kind: :date }, strict: true

  def index
    users = filter(User.all)
    render json: users
  end
end
```

Request examples:
```
GET /users?created_at=2021-01-01 # returns users created at 2021-01-01
GET /users?created_at=not_a_date # Raises a Filter::ValueError, with the message 'not_a_date' cannot be casted to date
```

## Handling invalid filter values in strict mode

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  rescue_from Filter::ValueError, with: :render_invalid_filter_value
  rescue_from Filter::RelationError, with: :render_invalid_filter_relation

  filterable_by age: { kind: :integer }, strict: true

  def index
    users = filter(User.all)
    render json: users
  end

  private

  # default handler for invalid filter values
  def render_invalid_filter_value(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def render_invalid_filter_relation(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
```

Request examples:
```
GET /users?age=18 # returns users with age 18
GET /users?age=not_an_integer
# returns a 400 (Bad Request), with the message "'not_an_integer' cannot be casted to integer"
```

## Referencing tables in the filterable fields

The `filterable_by` method can also be used to reference fields in associated tables. For example, to filter the users by the name of the company they work for, the following can be done:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by :name, 'companies.name', "companies.created_at" => { kind: :date_time }

  def index
    users = filter(User.joins(:company))
    render json: users
  end
end
```

Request examples:
```
GET /users?name=John
GET /users?companies.name=Acme
GET /users?companies.created_at=2021-01-01T00:00:00
```

## Renaming the filter query parameters

If you don't want to use the field name as the query parameter (as to not expose the database schema, or when joining the same table multiple times),
you can specify the query parameter to use for each field:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by 'companies.name' => { kind: :string, alias_name: :company_name },
                'users.name' => { kind: :string, alias_name: :user_name }


  def index
    users = filter(User.join(:company))
    render json: users
  end
end
```

Request examples:
```
GET /users?user_name=John
GET /users?company_name=Acme
```

## Using filters other than `eq`

By default, the `filter` method will use the `eq` filter method to filter the records. If you want to use a different filter method, you can specify the filter "relation" in the query parameter:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by name: { kind: :string }, age: { kind: :integer }

  def index
    users = filter(User.all)
    render json: users
  end
end
```

Request examples:
```
GET /users?name=John # returns users with name John
GET /users?name[]=John&name[]=Jane # returns users where the name is in ('John', 'Jane')
GET /users?age.rel=is_null # returns users where the age is null
GET /users?age.rel=is_not_null # returns users where the age is not null
GET /users?age.rel=between&age[]=18&age[]=30 # returns users with age between 18 and 30
GET /users?age.rel=gt&age=18 # returns users with age greater than 18
```

The full list of filter relations is:
- `eq` (default) - equals
- `neq` - not equals
- `gt` - greater than
- `gte` - greater than or equals
- `lt` - less than
- `lte` - less than or equals
- `between` - between (requires two values)
- `in` - in (default when multiple values are provided)
- `not_in` - not in (requires multiple values)
- `starts_with` - starts with
- `ends_with` - ends with
- `contains` - contains
- `is_null` - is null (does not require a value)
- `is_not_null` - is not null (does not require a  value)
