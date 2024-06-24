# Warped

Develop rails applications at the speed of thought. Warped is a collection of tools and utilities that make it easier to develop rails applications.


## Installation

Install the gem and add to the Rails application's Gemfile by executing:

    $ bundle add warped

Then run the generator to create the configuration file:

    $ rails generate warped:install

The generator will create a file at `config/initializers/warped.rb` with the default configuration.

### Installation for rails fullstack apps

For using the views provided by the gem, your app will need to have the following:
1. [rails/importmap-rails](https://github.com/rails/importmap-rails) configured
2. [hotwired/stimulus-rails](https://github.com/hotwired/stimulus-rails) configured

Add the following to your `config/importmap.rb`:

```ruby
pin_all_from "app/javascript/controllers/warped", under: "controllers/warped"
```

> This will import all the stimulus controllers provided by the gem.

Add the following to your `app/javascript/controllers/index.js`, bellow the `eagerLoadControllersFrom("controllers", application)` line:
```javascript
eagerLoadControllersFrom("warped/controllers", application)
```

Include the css provided by the gem in your `app/views/layouts/application.html.erb`:
```erb
<%= stylesheet_link_tag "warped/base" %>
<%= stylesheet_link_tag "warped/table" %>
<%= stylesheet_link_tag "warped/search" %>
<%= stylesheet_link_tag "warped/filters" %>
<%= stylesheet_link_tag "warped/pagination" %>
```

## Usage

Warped provides utilities for making it easier to develop rails applications. The utilities are organized into modules and can be used by including the module in the class that needs the utility.
The utilities are organized in concepts used by most rails applications:
- [Controllers](#controllers)
- [Services](#services)
- [Jobs](#jobs)

### Controllers

The `Warped::Controllers` module defines five concerns that can be included in a controller to provide additional functionality:
- [Warped::Controllers::Filterable](#warpedcontrollersfilterable)
- [Warped::Controllers::Searchable](#warpedcontrollersearchable)
- [Warped::Controllers::Sortable](#warpedcontrollerssortable)
- [Warped::Controllers::Paginatable](#warpedcontrollerspaginatable)
- [Warped::Controllers::Tabulatable](#warpedcontrollerstabulatable)

#### Warped::Controllers::Filterable

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
> [!TIP]
> It's highly recommended to use the type-safe filter methods provided by the gem. This prevents invalid queries from being executed on the database. See the [Filterable documentation](docs/controllers/FILTERABLE.md) for more information.

[Complete documentation for Warped::Controllers::Filterable](docs/controllers/FILTERABLE.md).

#### Warped::Controllers::Searchable

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
  include Warped::Controllers::Searchable

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

[Complete documentation for Warped::Controllers::Searchable](docs/controllers/SEARCHABLE.md).

#### Warped::Controllers::Sortable

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
> [!TIP]
> It's highly recommended to use the type-safe sort methods provided by the gem. This prevents invalid queries from being executed on the database. See the [Sortable documentation](docs/controllers/SORTABLE.md) for more information.

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

[Complete documentation for Warped::Controllers::Sortable](docs/controllers/SORTABLE.md).

#### Warped::Controllers::Pageable

The `Pageable` concern provides a method to paginate the records in a controller's action.

The method `paginate` is used to paginate the records.
It will use the query parameters `page` and `per_page` to paginate the records.

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Pageable

  def index
    users = paginate(User.all)
    render json: users, meta: pagination
  end
end
```

Request examples:
```
GET /users?page=1&per_page=10 # returns the first page of users with 10 records per page
GET /users?per_page=25 # returns the first page of users with 25 records per page
GET /users?page=2&per_page=25 # returns the second page of users with 25 records per page
```

[Complete documentation for Warped::Controllers::Pageable](docs/controllers/PAGEABLE.md).

#### Warped::Controllers::Tabulatable

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

[Complete documentation for Warped::Controllers::Tabulatable](docs/controllers/TABULATABLE.md).

### Views

Warped comes with a set of partials and stimulus controllers that can be used to make development of index views easier/faster.

In order to use the views provided by the gem, warped provides ::Ui modules for each of the before menttioned concerns. `These Warped::Controllers::<ConcernName>::Ui` provide the helper methods needed by the partials in order to work.

The partials are:
- `Warped::Controllers::Filterable::Ui` -> `warped/_filters.html.erb`
- `Warped::Controllers::Searchable::Ui` -> `warped/_search.html.erb`
- `Warped::Controllers::Pageable::Ui` -> `warped/_pagination.html.erb`
- `Warped::Controllers::Tabulatable::Ui` -> `warped/_table.html.erb`

Example:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  # first_name :string
  # last_name :string
  # email :string
  # created_at :datetime

  scope :search, ->(query) { where('first_name LIKE ? OR last_name LIKE ? OR email LIKE ?', "%#{query}%", "%#{query}%", "%#{query}%") }

end

# app/controllers/users_controller.rb
class UsersController < ApplicationControlelr
  include Warped::Controllers::Tabulatable::Ui

  tabulatable_by name: { kind: :string }, email: { kind: :string }, created_at: { kind: :date_time }

  def index
    @users = tabulate(User.all)
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end
end
```

```erb
# app/views/users/index.html.erb
<%= render "warped/table", collection: @users,
                           path: users_path,
                           columns: [
                             Warped::Table::Column.new(:id, 'ID'),
                             Warped::Table::Column.new(:full_name, 'Full Name', method: ->(user) { [user.first_name, user.last_name].compact_blank.join(" ") }),
                             Warped::Table::Column.new(:email),
                             Warped::Table::Column.new(:created_at, 'Created At', method: ->(user) { user.created_at.strftime('%Y-%m-%d') })
                           ],
                           actions: [
                             Warped::Table::Action.new('Show', ->(user) { user_path(user) }),
                             Warped::Table::Action.new('Delete', ->(user) { user_path(user) }, turbo_method: :delete, turbo_confirm: 'Are you sure?')
                           ],
                           turbo_action: :replace
                          %>
```
The code above, renders a table with:
- The columns `ID`, `Full Name`, `Email`, and `Created At`, all of which are sortable.
- The actions `Show` and `Delete` for each user. The action `Delete` will use the `DELETE` method and will ask for confirmation before executing the action.
- The filters for the `name`, `email`, and `created_at` fields.
- A search input that will search the users by the term provided.
- A pagination component that will paginate the users, showing 10 users per page by default.
- The table filtering/sorting/searching/pagination will be done using the [turbo-action=replace](https://turbo.hotwired.dev/handbook/frames#promoting-a-frame-navigation-to-a-page-visit).

[Complete documentation for Warped built-in Partials](docs/controllers/views/PARTIALS.md).
### Services

The gem provides a `Warped::Service::Base` class that can be used to create services in a rails application.

```ruby
class PrintService < Warped::Service::Base
  def call
    puts 'Hello, world!'
  end
end
```

The `call` method is the entry point for the service. It can be overridden to provide the service's functionality.

```ruby
class PrintService < Warped::Service::Base
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
class PrintService < Warped::Service::Base
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

[Complete documentation for Warped::Services](docs/services/README.md).

### Jobs

The gem provides a `Warped::Jobs::Base` class that can be used to create background jobs in a rails application.

```ruby
class PrintJob < Warped::Jobs::Base
  def perform
    puts 'Hello, world!'
  end
end
```

Warped::Jobs::Base is a subclass of ActiveJob::Base, and can be used as a regular ActiveJob job.

The superclass can be overriden to inherit from a different job class, by changing it in the `config/initializers/warped.rb` file.

```ruby
# config/initializers/warped.rb
Warped.configure do |config|
  config.job_superclass = 'ApplicationJob'
end
```

[Complete documentation for Warped::Jobs](docs/jobs/README.md).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gogrow-dev/warped. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gogrow-dev/warped/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Warped project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gogrow-dev/warped/blob/main/CODE_OF_CONDUCT.md).
