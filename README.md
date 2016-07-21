# Executor

This is a library for using threads with a similar interface to Java's ExecutorService.

## Usage

```ruby
require 'executor'
```

### ThreadPool
Create a pre-forked thread pool with 4 threads
```ruby
pool = Executor::ThreadPool.new(4)
```

Submit tasks

```ruby
future = pool.submit do
  puts "Working..."
  1 + 1
end
```
Get the result. This blocks until the result is ready
```ruby
puts future.get
# 2
```
Shutdown thread pool and wait for completion of all tasks
```ruby
pool.shutdown
pool.await_termination
```
Shutdown thread pool immediately and return the list of tasks waiting execution
```ruby
pool.shutdown!
```

### Worker
Create a pre-forked thread pool that executes the given block but with arguments given by calling `submit`

```ruby
worker = Executor::Worker(4) do |arg1, arg2|
  arg1 + arg2
end

future = worker.submit(10, 20)
puts future.get
# 30
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/executor.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
