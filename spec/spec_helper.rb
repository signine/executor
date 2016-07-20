$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'executor'

def ignore &block
    yield
rescue Exception => e
end
