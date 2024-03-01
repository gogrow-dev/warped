# Warped::Jobs

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
