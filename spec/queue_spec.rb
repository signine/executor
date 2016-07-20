require_relative 'spec_helper'
require 'executor/queue'

describe Executor::Queue do
  subject { Executor::Queue.new }

  describe '#push' do
    it 'adds to queue' do
      subject.push(1)
      expect(subject.pop).to eq(1)
    end
  end

  describe '#pop' do
    it 'removes first item from queue' do
      [1, 2].each { |i| subject.push(i) }
      expect(subject.pop).to eq(1)
    end

    it 'blocks when empty' do
      ret = nil
      th = Thread.new { ret = subject.pop }
      subject.push(1)
      th.join
      expect(ret).to eq(1)
    end
  end

  context 'when shutdown' do
    it 'does not accept new items' do
      subject.shutdown
      subject.push(1)
      expect(subject.size).to eq(0)
    end

    it 'raises exception after queue is empty' do
      [1, 2].each { |i| subject.push(i) }
      subject.shutdown
      2.times { subject.pop }
      expect { subject.pop }.to raise_exception Executor::Shutdown
    end
  end

end
