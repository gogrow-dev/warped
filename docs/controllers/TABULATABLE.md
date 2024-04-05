# Warped::Controllers::Tabulatable

The `Tabulatable` concern provides a method to filter, sort, search, and paginate the records in a controller's action.

The method `tabulate` is used to filter, sort, search, and paginate the records. So, in the case that the controller action needs to filter, sort, search, and paginate the records, the `tabulate` method can be used.

The tabulatable concern provides the `tabulatable_by` method, which passes the values to `filterable_by` and `sortable_by`.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Tabulatable

  tabulatable_by :name, :email, :created_at

  def index
    users = tabulate(User.all)
    render json: users, meta: pagination
  end
end
```

Request examples:
```
GET /users?age[]=18&age[]=30&age.rel=between&sort_key=name&sort_direction=asc&q=John&page=2&per_page=10
# returns the second page of users with 10 records per page, where the age is between 18 and 30, sorted by name in ascending order, and searched by the term John
```

Just like `paginate`, when calling the `tabulate` method in the controller action, the `pagination` method can be used to access the pagination information.
