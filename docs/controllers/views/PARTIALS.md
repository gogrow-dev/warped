# Using Warped built-in view partials

In order to use the built in Warped view partials, you need to include the `Warped::Controllers::<WarpedConcern>::Ui` module in your controller.

## Warped::Controllers::Filterable::Ui
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Warped::Controllers::Filterable::Ui

  def index
    @users = filter(User.all)
  end
end
```

```erb
<!-- app/views/users/index.html.erb -->

<%= render "warped/filters", path: users_path, turbo_action: "replace" %>

<% @users.each do |user| %>
  <p><%= user.first_name %>, <%= user.last_name %></p>
<% end %>
```

The `warped/_filters` partial uses [strict locals](https://edgeguides.rubyonrails.org/action_view_overview.html#strict-locals), and it accepts:
- `path` - the path to the controller action to which the filters will be applied
- `turbo_action` - the Turbo action to be used when submitting the form (replace/advance)

The partial also accepts the following optional locals:
- `class`: the class to be applied to the form
- `data`: a hash of data attributes to be applied to the form
Any other locals that are passed to the partial will be passed to the `form_with` helper.

The `warped/_filters` partial will also render a set of hidden fields to store the sortable and searchable values, if the controller action called `#search` or `#sort`

## Warped::Controllers::Pageable::Ui
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Warped::Controllers::Pageable::Ui

  def index
    @users = paginate(User.all)
  end
end
```

```erb
<!-- app/views/users/index.html.erb -->

<% @users.each do |user| %>
  <p><%= user.first_name %>, <%= user.last_name %></p>
<% end %>

<%= render "warped/pagination", path: users_path, turbo_action: "replace" %>
```

The `warped/_pagination` partial uses [strict locals](https://edgeguides.rubyonrails.org/action_view_overview.html#strict-locals), and it accepts:
- `path` - the path to the controller action to which the pagination will be applied
- `turbo_action` - the Turbo action to be used when submitting the form (replace/advance)

Any other locals that are passed to the partial will be passed to the pagination <nav> tag.

The `warped/_pagination` partial will also render a set of hidden fields for each button, to store the sortable, searchable and filterable values, if the controller action called `#search`, `#sort` or `#filter`.

## Warped::Controllers::Searchable::Ui
```ruby
# app/models/user.rb

class User < ApplicationRecord

  scope :search, ->(query) {
    where("first_name ILIKE :query OR last_name ILIKE :query", query: "%#{query}%")
  }
end
```

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Warped::Controllers::Searchable::Ui

  def index
    @users = search(User.all)
  end
end
```

```erb
<!-- app/views/users/index.html.erb -->

<%= render "warped/search", path: users_path, turbo_action: "replace" %>

<% @users.each do |user| %>
  <p><%= user.first_name %>, <%= user.last_name %></p>
<% end %>
```

The `warped/_search` partial uses [strict locals](https://edgeguides.rubyonrails.org/action_view_overview.html#strict-locals), and it accepts:
- `path` - the path to the controller action to which the search will be applied
- `turbo_action` - the Turbo action to be used when submitting the form (replace/advance)
Any other locals that are passed to the partial will be passed to the search `form_with` helper.

The `warped/_search` partial will also render a set of hidden fields to store the sortable, filterable and pagination values, if the controller action called `#sort`, `#filter` or `#paginate`.

## Warped::Controllers::Tabulatable::Ui
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Warped::Controllers::Tabulatable::Ui

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
<!-- app/views/users/index.html.erb -->

<%= render "warped/table", collection: @users, path: users_path, turbo_action: "replace",
                           columns: [
                              Warped::Table::Column.new(:first_name, "First Name"),
                              Warped::Table::Column.new(:last_name, "Last Name")
                           ],
                           actions: [
                              Warped::Table::Action.new(:show, ->(user) { user_path(user) }),
                              Warped::Table::Action.new(:destroy, ->(user) { user_path(user) }, data: { turbo_method: "delete", turbo_confirm: "Are you sure?" })
                           ] %>
```

The `warped/_table` partial uses [strict locals](https://edgeguides.rubyonrails.org/action_view_overview.html#strict-locals), and it accepts:
- `collection` - the collection of records to be displayed
- `path` - the path to the controller action to which the table filtering/sorting/searching/pagination will be applied
- `turbo_action` - the Turbo action to be used when submitting the form (replace/advance)
- `columns` - an array of `Warped::Table::Column` objects that define the columns to be displayed
- `actions` - an array of `Warped::Table::Action` objects that define the actions to be displayed for each record
Any other locals under the keys `:table`, `:filters`, `:search` or `:pagination` are passed to the respective partials.
Example:
```erb
<%= render "warped/table", collection: @users, path: users_path, turbo_action: "replace",
                           columns: [
                             Warped::Table::Column.new(:first_name, "First Name"),
                             Warped::Table::Column.new(:last_name, "Last Name")
                           ],
                           actions: [
                             Warped::Table::Action.new(:show, ->(user) { user_path(user) }),
                             Warped::Table::Action.new(:destroy, ->(user) { user_path(user) }, data: { turbo_method: "delete", turbo_confirm: "Are you sure?" })
                           ],
                           table: { class: "table" },
                           filters: { class: "filters" },
                           search: { class: "search" },
                           pagination: { class: "pagination" } %>
```
This will render the table with the class `table`, and it will forward the locals:
- `class: "filters"` to the `warped/_filters` partial
- `class: "search"` to the `warped/_search` partial
- `class: "pagination"` to the `warped/_pagination` partial

### Using the `Warped::Table::Column` class
The `Warped::Table::Column` class is used to define the columns to be displayed in the table. The initializer accepts the following arguments:
- `parameter_name` - the name of the parameter/alias_name passed to the `filterable_by`/`sortable_by`/`tabulatable_by` methods
- `display_name`(optional) - the name to be displayed in the table header
- `method`(optional) - this can be a symbol or a lambda. If the method is a symbol, it will be called on the record to get the value. If the method is a lambda, it will be called with the record as an argument.

### Using the `Warped::Table::Action` class
The `Warped::Table::Action` class is used to define the actions to be displayed for each record in the table. The initializer accepts the following arguments:
- `name` - the name of the action. If the name is a symbol or a string, it will be used as the action name. If the name is a lambda, it will be called with the record as an argument.
- `path` - the path to the controller action to which the action will be applied. If the path is a lambda, it will be called with the record as an argument.


## Using turbo-frames with the partials
The partials can be used with turbo-frames to provide a seamless experience, regardless of the action used in the controller.

```ruby
# app/controllers/user_controller.rb
class UserController < ApplicationController
  include Warped::Controllers::Tabulatable::Ui

  tabulatable_by title: { kind: :string }, published_at: { kind: :date_time },

  def show
    @user = current_user
    @posts = tabulate(@user.posts)
  end
end
```

```erb
<!-- app/views/users/show.html.erb -->
<h1><%= @user.name %></h1>

<%= turbo_frame_tag dom_id(@posts) do %>
  <%= render "warped/table", collection: @posts, path: user_path, turbo_action: "advance",
                             columns: [
                               Warped::Table::Column.new(:title, "Title"),
                               Warped::Table::Column.new(:published_at, "Published At")
                             ],
                             actions: [
                               <%# pass target: "_top" to the action, to escape from the turbo_frame navigation %>
                               Warped::Table::Action.new(:show, ->(post) { post_path(post) }, target: "_top")
                             ] %>
<% end %>
```

## Styling the partials
The partials are designed to be as unobtrusive as possible, and they can be styled using the classes passed as locals to the partials, or by modifying the partials css classes.

The css classes are in the following files:
– `app/assets/stylesheets/warped/base.css` - the base css variables
- `app/assets/stylesheets/warped/filters.css` - the css classes for the filters partial
- `app/assets/stylesheets/warped/pagination.css` - the css classes for the pagination partial
- `app/assets/stylesheets/warped/search.css` - the css classes for the search partial
- `app/assets/stylesheets/warped/table.css` - the css classes for the table partial

You can override the css classes by adding the following to your css file:
```css
@import "warped/base.css";
@import "warped/filters.css";
@import "warped/pagination.css";
@import "warped/search.css";
@import "warped/table.css";
```

## Moving logic from the view to the controller
Using the "warped/_table" can introduce a lot of logic in the view. To move the logic to the controller, you can instantiate the Columns and Actions in the controller and use them in the view as instance variables.

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include Warped::Controllers::Tabulatable::Ui

  helper_method :columns_for_index, :actions_for_index

  tabulatable_by first_name: { kind: :string },
                 last_name: { kind: :string },
                 email: { kind: :string },
                 created_at: { kind: :date_time, alias_name: :registered_at },
                 status: { kind: :date_time }

  def index
    users_query = User.all.select("users.*, CASE WHEN confirmed_at IS NULL THEN 'Inactive' ELSE 'Active' END AS status")
    @users = tabulate(users_query)
  end

  ...

  private

  def columns_for_index
    [
      Warped::Table::Column.new(:first_name, "First Name"),
      Warped::Table::Column.new(:last_name, "Last Name"),
      Warped::Table::Column.new(:email, "Email"),
      Warped::Table::Column.new(:registered_at, "Registered At"),
      Warped::Table::Column.new(:status, "Status")
    ]
  end

  def actions_for_index
    [
      Warped::Table::Action.new(:show, ->(user) { user_path(user) }),
      Warped::Table::Action.new(:edit, ->(user) { edit_user_path(user) }),
      Warped::Table::Action.new(:destroy, ->(user) { user_path(user) }, data: { turbo_method: "delete", turbo_confirm: "Are you sure?" })
    ]
  end
```

```erb
<!-- app/views/users/index.html.erb -->
<%= render "warped/table", collection: @users, path: users_path, turbo_action: "replace",
                           columns: columns_for_index,
                           actions: actions_for_index %>
```
