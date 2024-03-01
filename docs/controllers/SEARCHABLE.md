# Warped::Controllers::Searchable

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

## Customizing the search query parameter

You can customize the default query parameter by:
1. Passing fetching the fetch term from the params hash, and passing it directly to the search method:

```ruby
class UsersController < ApplicationController
  include Warped::Controllers::Searchable

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
  include Warped::Controllers::Searchable

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
  include Warped::Controllers::Searchable

  # This will use the query parameter `term` instead of `q`
  # and the search scope `search_by_word` instead of the default
  searchable_by :search_by_word, param: :term

  def index
    users = search(User.all)
    render json: users
  end
end
```
