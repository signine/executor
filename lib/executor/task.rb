require 'thread'
require_relative 'future'

module Executor
  class Task

    attr_reader :result, :error

    class CancelledException < RuntimeError; end

    STATE = {
      queued:    1,
      running:   2,
      finished:  3,
      error:     4,
      cancelled: 5,
    }

    def initialize(proc, *args)
      @proc       = proc
      @args       = args
      @state      = STATE[:queued]
      @result     = nil
      @error      = nil
      @run_lock   = Mutex.new
      @state_lock = Mutex.new
    end

    def run
      @run_lock.synchronize do
        return unless queued?

        begin
          change_to STATE[:running]
          @thread = Thread.current
          @result = @proc.call(*@args)
          change_to STATE[:finished]
        rescue CancelledException => e
          change_to STATE[:cancelled]
        rescue Exception => e
          change_to STATE[:error]
          @error = e
          raise e
        ensure
          cv.broadcast
        end
      end
    end

    def cancel
      cancel_task
    end

    # Not safe! Avoid using this
    def cancel!
      cancel_task true
    end

    def cancelled?
      @state == STATE[:cancelled]
    end

    def finished?
      @state == STATE[:finished]
    end

    def error?
      @state == STATE[:error]
    end

    def completed?
      finished? || error?
    end

    def queued?
      @state == STATE[:queued]
    end

    def running?
      @state == STATE[:running]
    end

    def wait_until_complete timeout=nil
      @state_lock.synchronize do
        cv.wait(@state_lock, timeout) unless completed? || cancelled?
      end
    end

    def future
      @future ||= Future.new(self)
    end

    private

    def cv
      @cv ||= ConditionVariable.new
    end

    def change_to state
      @state_lock.synchronize { @state = state }
    end

    def cancel_task force=false
      @state_lock.synchronize do
        if queued?
          @state = STATE[:cancelled]
        elsif running?
          @state = STATE[:cancelled]
          @thread.raise CancelledException.new if force == true
        end
      end
    end

  end
end
