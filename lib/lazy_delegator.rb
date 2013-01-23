require 'delegate'

class LazyDelegator < Delegator
  def initialize(&block)
    @block = block
  end
  def __getobj__
    @obj ||= @block.call
  end
end
