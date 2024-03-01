# Warped::Controllers::Pageable

The `Pageable` concern provides a method to paginate the records in a controller's action.

The method `paginate` is used to paginate the records.
It will use the query parameters `page` and `per_page` to paginate the records.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Pageable

  def index
    users = paginate(User.all)
    render json: users, meta: page_info
  end
end
```

Request examples:
```
GET /users?page=1&per_page=10 # returns the first page of users with 10 records per page
GET /users?per_page=25 # returns the first page of users with 25 records per page
GET /users?page=2&per_page=25 # returns the second page of users with 25 records per page
```

## Accessing the pagination information

The `page_info` method can be used to access the pagination information.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Pageable

  def index
    users = paginate(User.all)
    render json: users, meta: page_info
  end
end
```

`page_info` returns a hash with
- `page` - the current page
- `per_page` - the number of records per page
- `total_pages` - the total number of pages
- `total_count` - the number of records in the scope
- `next-page` - the next page number
- `prev-page` - the previous page number


## Customizing the pagination behavior

By default, the `paginate` method will paginate the scope in pages of size 10, and will return the first page if the `page` query parameter is not provided.

Additionally, there's a limit of `100` records per page. So, if the `per_page` query parameter is greater than `100`, the pagination will use `100` as the page size.

You can customize the default page size and the default page number by overriding the `default_per_page` value in the controller.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Pageable

  # This will set the default page size to 25 when the `per_page` query parameter is not provided
  self.default_per_page = 25

  def index
    users = paginate(User.all)
    render json: users, meta: page_info
  end
end
```
