require "executor/version"
require "executor/task"
require "executor/future"
require "executor/queue"
require "executor/thread_pool"
require "executor/worker"

module Executor
  class Shutdown < StandardError; end
end
