require_relative 'spec_helper'
require 'executor/task'

describe Executor::Task do
  let(:proc) { Proc.new { 1 + 1 } }
  subject { Executor::Task.new(proc) }

  describe '#run' do
    it 'runs task' do
      subject.run
      expect(subject.result).to eq(2)
    end

    it 'runs at most once' do
      run_times = 0
      e = Executor::Task.new Proc.new { run_times+= 1 }
      e.run
      e.run
      expect(run_times).to eq(1)
    end

    it 'passes arguments' do
      p = Proc.new do |arg1, arg2|
        expect(arg1).to eq(1)
        expect(arg2).to eq(2)
      end

      e = Executor::Task.new p, 1, 2
      e.run
    end

    context 'when task raises exception' do
      let(:exception) { StandardError.new }
      subject { Executor::Task.new Proc.new { raise exception } }
      before { subject.run }

      it('stores exception from task') { expect(subject.error).to eq(exception) }
      it('sets state to error') { expect(subject.error?).to eq(true) }
    end
  end

  describe '#queued?' do
    it 'returns true before the task is run' do
      expect(subject.queued?).to eq(true)
    end
  end

  describe '#finished?' do
    it 'returns true after the task is finished' do
      subject.run
      expect(subject.finished?).to eq(true)
    end
  end

  describe '#completed?' do
    it 'returns true if task is finished' do
      subject.run
      expect(subject.completed?).to eq(true)
    end

    it 'returns true if task finished with error' do
      p = Proc.new { raise StandardError.new }
      s = Executor::Task.new(p)
      s.run
      expect(s.completed?).to eq(true)
    end
  end

  describe '#wait_until_complete' do
    it 'blocks until task is completed' do
      p = Proc.new { sleep 0.5 }
      e = Executor::Task.new(p)
      th = Thread.new { e.run }
      e.wait_until_complete
      expect(e.completed?).to eq(true)
    end

    it 'blocks until timeout is reached' do
      p = Proc.new { sleep 5 }
      e = Executor::Task.new(p)
      th = Thread.new { e.run }
      e.wait_until_complete(0.5)
      expect(e.completed?).to eq(false)
    end
  end

  describe '#cancel' do
    it 'sets state to cancelled' do
      subject.cancel
      expect(subject.cancelled?).to eq(true)
    end

    it 'does not interrupt task if already running' do
      m = Mutex.new
      cv = ConditionVariable.new
      p = Proc.new { cv.signal; true }
      e = Executor::Task.new(p)
      th = Thread.new { e.run }

      m.synchronize { cv.wait(m) }
      e.cancel
      th.join
      expect(e.result).to eq(true)
    end
  end

  describe '#cancel!' do
    it 'kills running task' do
      m = Mutex.new
      cv = ConditionVariable.new
      p = Proc.new { cv.signal; sleep(4); true }
      e = Executor::Task.new(p)
      th = Thread.new { e.run }

      m.synchronize { cv.wait(m) }
      e.cancel!
      th.join
      expect(e.result).to eq(nil)
    end
  end

  describe '#future' do
    it 'returns future of task' do
      expect(subject.future).to be_a(Executor::Future)
    end
  end

end
