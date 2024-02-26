# Boosted

Develop rails applications at the speed of thought. Boosted is a collection of tools and utilities that make it easier to develop rails applications.


## Installation

Install the gem and add to the Rails application's Gemfile by executing:

    $ bundle add boosted-rails

Then run the generator to create the configuration file:

    $ rails generate boosted:install

The generator will create a file at `config/initializers/boosted.rb` with the default configuration.

## Usage

Boosted provides utilities for making it easier to develop rails applications. The utilities are organized into modules and can be used by including the module in the class that needs the utility.
The utilities are organized in concepts used by most rails applications:
- [Controllers](#controllers)
- [Services](#services)
- [Jobs](#jobs)

### Controllers

The `Boosted::Controllers` module defines five concerns that can be included in a controller to provide additional functionality:
- [Boosted::Controllers::Filterable](#boostedcontrollersfilterable)
- [Boosted::Controllers::Searchable](#boostedcontrollersearchable)
- [Boosted::Controllers::Sortable](#boostedcontrollerssortable)
- [Boosted::Controllers::Paginatable](#boostedcontrollerspaginatable)
- [Boosted::Controllers::Tabulatable](#boostedcontrollerstabulatable)

#### Boosted::Controllers::Filterable

The `Filterable` concern provides a method to filter the records in a controller's action.
The method `filterable_by` is used to define the filterable fields and the filter method to use.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Filterable

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

##### Referencing tables in the filterable fields

The `filterable_by` method can also be used to reference fields in associated tables. For example, to filter the users by the name of the company they work for, the following can be done:

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Filterable

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

##### Renaming the filter query parameters

If you don't want to use the field name as the query parameter (as to not expose the database schema, or when joining the same table multiple times),
you can specify the query parameter to use for each field:

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Filterable

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

##### Using filters other than `eq`

By default, the `filter` method will use the `eq` filter method to filter the records. If you want to use a different filter method, you can specify the filter "relation" in the query parameter:

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Filterable

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

#### Boosted::Controllers::Searchable

The `Searchable` concern provides a method to search the records in a controller's action.

By default it calls the scope `search` on the model, and uses the query parameter `q` to search the records.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # You can define your own search scope and use standard sql
  # scope :search, ->(query) { where('name LIKE ?', "%#{query}%") }

  # Or use pg_search
  include PgSearch::Model
  pg_search_scope :search, against: [:name, :email]
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Boosted::Controllers::Searchable

  def index
    users = search(User.all)
    render json: users
  end
end
```

Request examples:
```
GET /users?q=John
# calls #search(User.all, search_term: 'John', model_search_scope: :search) in the controller
```

##### Customizing the search query parameter

You can customize the default query parameter by:
1. Passing fetching the fetch term from the params hash, and passing it directly to the search method:

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Searchable

  def index
    # This will use the query parameter `term` instead of `q`
    users = search(User.all, search_term: params[:term])
    render json: users
  end
end
```

2. Overriding the `search_param` method in the controller

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Searchable

  def index
    # This will use the query parameter `term` instead of `q`
    users = search(User.all)
    render json: users
  end

  private

  def search_param
    :term
  end
end
```

3. Calling #searchable_by in the controller and overriding the default query parameter

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_word, against: :name, using: { tsearch: { any_word: true } }
end


# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Boosted::Controllers::Searchable

  # This will use the query parameter `term` instead of `q`
  # and the search scope `search_by_word` instead of the default
  searchable_by :search_by_word, param: :term

  def index
    users = search(User.all)
    render json: users
  end
end
```

#### Boosted::Controllers::Sortable

The `Sortable` concern provides a method to sort the records in a controller's action.

The method `sortable_by` is used to define the sortable fields.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Sortable

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
  include Boosted::Controllers::Sortable

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
##### Referencing tables in the sortable fields

Like the `filterable_by` method, the `sortable_by` method can also be used to reference fields in associated tables.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Sortable

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

##### Renaming the sort query parameters

If you don't want to use the field name as the query parameter (as to not expose the database schema, or when joining the same table multiple times),
you can specify the query parameter to use for each field:

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Sortable

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

#### Boosted::Controllers::Pageable

The `Pageable` concern provides a method to paginate the records in a controller's action.

The method `paginate` is used to paginate the records.
It will use the query parameters `page` and `per_page` to paginate the records.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Pageable

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

##### Accessing the pagination information

The `page_info` method can be used to access the pagination information.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Pageable

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


##### Customizing the pagination behavior

By default, the `paginate` method will paginate the scope in pages of size 10, and will return the first page if the `page` query parameter is not provided.

Additionally, there's a limit of `100` records per page. So, if the `per_page` query parameter is greater than `100`, the pagination will use `100` as the page size.

You can customize the default page size and the default page number by overriding the `default_per_page` value in the controller.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Pageable

  # This will set the default page size to 25 when the `per_page` query parameter is not provided
  self.default_per_page = 25

  def index
    users = paginate(User.all)
    render json: users, meta: page_info
  end
end
```

#### Boosted::Controllers::Tabulatable

The `Tabulatable` concern provides a method to filter, sort, search, and paginate the records in a controller's action.

The method `tabulate` is used to filter, sort, search, and paginate the records. So, in the case that the controller action needs to filter, sort, search, and paginate the records, the `tabulate` method can be used.

The tabulatable concern provides the `tabulatable_by` method, which passes the values to `filterable_by` and `sortable_by`.

```ruby
class UsersController < ApplicationController
  include Boosted::Controllers::Tabulatable

  tabulatable_by :name, :email, :created_at

  def index
    users = tabulate(User.all)
    render json: users, meta: page_info
  end
end
```

Request examples:
```
GET /users?age[]=18&age[]=30&age.rel=between&sort_key=name&sort_direction=asc&q=John&page=2&per_page=10
# returns the second page of users with 10 records per page, where the age is between 18 and 30, sorted by name in ascending order, and searched by the term John
```

Just like `paginate`, when calling the `tabulate` method in the controller action, the `page_info` method can be used to access the pagination information.

### Services

The gem provides a `Boosted::Service::Base` class that can be used to create services in a rails application.

```ruby
class PrintService < Boosted::Service::Base
  def call
    puts 'Hello, world!'
  end
end
```

The `call` method is the entry point for the service. It can be overridden to provide the service's functionality.

```ruby
class PrintService < Boosted::Service::Base
  def call
    puts "Hello, #{name}!"
  end

  private

  def name
    'world'
  end
end
```

The way of calling the service is by calling the `call` method on the service class.
The .call method is a class method that creates a new instance of the service, passing the arguments to the `initialize` method, and then calls the `call` method on the new instance.

```ruby
PrintService.call # Executes new.call
```

If you want to pass arguments to the service, you can so by defining the `initialize` method in the service class.

```ruby
class PrintService < Boosted::Service::Base
  def initialize(name = 'John')
    @name = name
  end

  def call
    puts "Hello, #{@name}!"
  end
end
```

```ruby
PrintService.call # Executes new.call, prints "Hello, John!"
PrintService.call('world') # Executes new('world').call, prints "Hello, world!"
```

##### Using services as job classes in the background

The `Boosted::Service::Base` class provides a class method `.enable_job!` that can be used to enable the service to be used as a job class.

```ruby
class PrintService < Boosted::Service::Base
  enable_job!

  def call
    puts 'Hello, world!'
  end
end
```

The `enable_job!` method will define a `PrintService::Job` class that inherits from `Boosted::Jobs::Base` and calls the `call` method on the service instance.

```ruby
PrintService.call_later # Executes PrintService::Job.perform_later
PrintService::Job.perform_later # Executes PrintService.new.call in the background
```

call_later and perform_later will pass the arguments to the `initialize` method of the service class, and then call the `call` method on the new instance.

```ruby
PrintService.call_later('world') # Executes PrintService::Job.perform_later('world')
PrintService::Job.perform_later('world') # Executes PrintService.new('world').call in the background
```

### Jobs

The gem provides a `Boosted::Jobs::Base` class that can be used to create background jobs in a rails application.

```ruby
class PrintJob < Boosted::Jobs::Base
  def perform
    puts 'Hello, world!'
  end
end
```

Boosted::Jobs::Base is a subclass of ActiveJob::Base, and can be used as a regular ActiveJob job.

The superclass can be overriden to inherit from a different job class, by changing it in the `config/initializers/boosted.rb` file.

```ruby
# config/initializers/boosted.rb
Boosted.configure do |config|
  config.job_superclass = 'ApplicationJob'
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gogrow-dev/boosted. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gogrow-dev/boosted/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Boosted project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gogrow-dev/boosted/blob/main/CODE_OF_CONDUCT.md).
