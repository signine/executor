module Executor
  class Future

    def initialize(task)
      @task = task
    end

    def cancel
      @task.cancel
    end

    def cancel!
      @task.cancel!
    end

    def cancelled?
      @task.cancelled?
    end

    def done?
      @task.completed?
    end

    def get timeout=nil
      @task.wait_until_complete timeout

      if @task.finished?
        @task.result
      elsif @task.error?
        raise @task.error
      end
    end

  end
end
