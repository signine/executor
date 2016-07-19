module Executor
  class Queue

    class ShutdownException < StandardError; end

    def initialize
      @queue  = Array.new
      @mutex  = Mutex.new
      @cv     = ConditionVariable.new
      @active = true
    end

    def push(obj)
      return unless active?

      @queue << obj
      @cv.signal
    end

    def pop
      @mutex.synchronize do
        if @queue.empty? && !active?
          raise ShutdownException
        elsif @queue.empty?
          cv.wait(@mutex)
        else
          @queue.shift
        end
      end
    end

    def shutdown
      @active = false
    end

    def size
      @queue.length
    end

    private

    def active?
      @active == true
    end

  end
end
