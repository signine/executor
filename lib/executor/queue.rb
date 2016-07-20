require_relative '../executor'

module Executor
  class Queue

    def initialize
      @items  = Array.new
      @mutex  = Mutex.new
      @cv     = ConditionVariable.new
      @active = true
    end

    def push(obj)
      unless shutdown?
        @items << obj
        @cv.signal
      end
    end

    def pop
      @mutex.synchronize do
        @cv.wait(@mutex) if @items.empty? && !shutdown?
        raise Shutdown if @items.empty? && shutdown?

        @items.shift
      end
    end

    def shutdown
      @mutex.synchronize do
        @active = false
        @cv.broadcast
      end
    end

    def shutdown?
      !@active
    end

    def size
      @items.length
    end

    def items
      @items.clone
    end

    def empty?
      @items.empty?
    end

  end
end
