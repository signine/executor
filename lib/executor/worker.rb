module Executor
  class Worker < ThreadPool

    def initialize size, &block
      raise ArgumentError, "Block required" unless block_given?
      @proc = block
      super size
    end

    def submit *args
      super { @proc.call(*args) }
    end

  end
end
