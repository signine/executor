require_relative 'task'
require_relative 'queue'
require_relative '../executor'

module Executor
  class ThreadPool
    def initialize size
      @size        = size
      @queue       = Queue.new
      @cv          = ConditionVariable.new
      @death_mutex = Mutex.new
      
      fork_threads
    end

    def submit &block
      task = Executor::Task.new block
      @queue.push task
      task.future
    end

    def shutdown
      @queue.shutdown
    end

    def shutdown!
      @queue.shutdown
      @threads.each { |t| t.raise Shutdown }
      @queue.items
    end

    def shutdown?
      @queue.shutdown?
    end

    def terminated?
      shutdown? && @queue.empty?
    end

    # TODO: Refactor this
    def await_termination timeout=nil
      raise StandardError, "Executor has not been shutdown" unless shutdown?

      @death_mutex.synchronize do
        @cv.wait(@death_mutex, timeout) if @threads.any? {|t| t.alive? }
      end
    end

    private

    def fork_threads
      @threads ||= Array.new(@size).map do
        Thread.new do
          loop do
            begin
              proc = @queue.pop
              proc.run
            rescue Shutdown
              break
            rescue Exception => e
              puts 'in here'
              puts e.message
              puts e.backtrace
            end
          end

          @death_mutex.synchronize do
            @cv.broadcast if @threads.select { |t| t.alive? }.length == 1
          end
        end
      end
    end

  end
end
