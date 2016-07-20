require_relative 'spec_helper'
require 'executor/future'

describe Executor::Future do
  describe '#get' do
    subject { @task.future }

    it 'returns result' do
      @task = Executor::Task.new(Proc.new{ 1 })
      @task.run
      expect(subject.get).to eq(1)
    end

    it 'raises exception if task returns error' do
      @task = Executor::Task.new(Proc.new{ raise Exception })
      ignore { @task.run }
      expect {subject.get}.to raise_exception(Exception)
    end

    it 'blocks until task is finished' do
      @task = Executor::Task.new(Proc.new{ sleep(1); true })
      th = Thread.new { @task.run }
      expect(subject.get).to eq(true)
    end

    it 'blocks until timeout' do
      @task = Executor::Task.new(Proc.new{ sleep(5); true })
      th = Thread.new { @task.run }
      expect(subject.get(0.5)).to eq(nil)
    end

  end
end
