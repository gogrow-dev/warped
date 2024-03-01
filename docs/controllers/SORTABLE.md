# Warped::Controllers::Sortable

The `Sortable` concern provides a method to sort the records in a controller's action.

The method `sortable_by` is used to define the sortable fields.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Sortable

  sortable_by :name, :created_at

  def index
    users = sort(User.all)
    render json: users
  end
end
```

This will use the query parameter `sort_key` and `sort_direction` to sort the records.
- The default sort direction is `desc`.
- The default sort key is `:id`.

Example requests:
```
GET /users?sort_key=name # sort by name in descending order
GET /users?sort_key=created_at&sort_direction=asc # sort by created_at in ascending order
```

When calling sort in a controller action, and the sort parameters are not provided, the default sort key and direction will be used.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Sortable

  sortable_by :name, :created_at

  def index
    users = sort(User.all)
    render json: users
  end
end
```

Request examples:
```
GET /users # sort by id in descending order
```
## Referencing tables in the sortable fields

Like the `filterable_by` method, the `sortable_by` method can also be used to reference fields in associated tables.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Sortable

  sortable_by :name, 'companies.name'

  def index
    users = sort(User.joins(:company))
    render json: users
  end
end
```

Request examples:
```
GET /users?sort_key=name # sort by name in descending order
GET /users?sort_key=companies.name&sort_direction=asc # sort by company name in ascending order
```

## Renaming the sort query parameters

If you don't want to use the field name as the query parameter (as to not expose the database schema, or when joining the same table multiple times),
you can specify the query parameter to use for each field:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Sortable

  sortable_by 'companies.name' => :company_name, 'users.name' => :user_name

  def index
    users = sort(User.join(:company))
    render json: users
  end
end
```

Request examples:
```
GET /users?sort_key=user_name # sort by name in descending order
GET /users?sort_key=company_name&sort_direction=asc # sort by company name in ascending order
```
