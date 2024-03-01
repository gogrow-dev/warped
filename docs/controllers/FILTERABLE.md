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

## Referencing tables in the filterable fields

The `filterable_by` method can also be used to reference fields in associated tables. For example, to filter the users by the name of the company they work for, the following can be done:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by :name, :email, :created_at, 'companies.name'

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
```

## Renaming the filter query parameters

If you don't want to use the field name as the query parameter (as to not expose the database schema, or when joining the same table multiple times),
you can specify the query parameter to use for each field:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Filterable

  filterable_by 'companies.name' => :company_name, 'users.name' => :user_name

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

  filterable_by :name, :age

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
GET /users?age.rel=%3E%0A&age=18 # returns users with age greater than 18, %3E%0A is url encoded for ">"
```

The full list of filter relations is:
- `=` (default) - equals
- `!=` - not equals
- `>` - greater than
- `>=` - greater than or equals
- `<` - less than
- `<=` - less than or equals
- `between` - between (requires two values)
- `in` - in (default when multiple values are provided)
- `not_in` - not in (requires multiple values)
- `starts_with` - starts with
- `ends_with` - ends with
- `contains` - contains
- `is_null` - is null (does not require a value)
- `is_not_null` - is not null (does not require a  value)
