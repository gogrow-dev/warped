# Warped::Services

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

## Using services as job classes in the background

The `Warped::Service::Base` class provides a class method `.enable_job!` that can be used to enable the service to be used as a job class.

```ruby
class PrintService < Warped::Service::Base
  enable_job!

  def call
    puts 'Hello, world!'
  end
end
```

The `enable_job!` method will define a `PrintService::Job` class that inherits from `Warped::Jobs::Base` and calls the `call` method on the service instance.

```ruby
PrintService.call_later # Executes PrintService::Job.perform_later
PrintService::Job.perform_later # Executes PrintService.new.call in the background
```

call_later and perform_later will pass the arguments to the `initialize` method of the service class, and then call the `call` method on the new instance.

```ruby
PrintService.call_later('world') # Executes PrintService::Job.perform_later('world')
PrintService::Job.perform_later('world') # Executes PrintService.new('world').call in the background
```
