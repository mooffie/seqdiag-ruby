
class Model
  attr_accessor :identifier

  def initialize(identifier, label, options = {})
    @identifier = identifier
    needs_new = options[:needs_new] ? '/' : ''
    flags = options[:flags] || 'r'
    puts '%s%s:Object[%s] "%s"' % [needs_new, identifier, flags, label]
  end

  def method_missing(method, *args, &block)
    #puts "* missing #{method}"
    options = args.last.respond_to?(:merge) ? args.pop : {}

    caller  = current_active
    callee  = self.identifier
    params  = args.first ? "(#{args.first})" : '()'
    cond    = options[:cond] ? "#{options[:cond]} " : ''
    ids     = options[:ids] ? "(#{options[:ids] * ','})" : ''
    return_v = options[:return] ? "#{options[:return]}=" : ''

    puts '%s%s:%s%s.%s%s%s'% [ids, caller, return_v, callee, cond, method, params]

    if block_given?
      self.class.push_active_object(self)
      yield
      self.class.pop_active_object
    end
  end

  def current_active
    self.class.get_active_object.identifier
  end

  #######

  def self.active_stack
    @active_stack ||= []
  end

  def self.get_active_object
    active_stack.last
  end

  def self.push_active_object(obj)
    active_stack.push obj
  end

#  def self.start_with(obj)
#    push_active_object(obj)
#    puts ' '
#  end

  def self.pop_active_object
    active_stack.pop
  end

end

def start_with(obj) # :yield:
  puts ' '
  Model.push_active_object(obj)
  yield
end

def line(message = '_')
  message.gsub!('.', '\\.')
  puts '%s:%s' % [Model.get_active_object.identifier, message]
end

def note(message, options = {})
  right_of = (options[:right_of] || Model.get_active_object).identifier
  attach_to = options[:attach_to] ? options[:attach_to] : 1000
  puts "*%s %s" % [attach_to, right_of]
  puts message
  puts "*%s" % [attach_to]
end
