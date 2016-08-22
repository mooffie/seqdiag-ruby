
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
    params  = args.first ? "(#{args.first})" : (method != :new ? '()' : '')
    cond    = options[:cond] ? "#{options[:cond]} " : ''
    ids     = options[:ids] ? "(#{options[:ids] * ','})" : ''
    return_v = options[:return] ? "#{options[:return]}=" : ''

    if options[:text]
      method = options[:text]
      params = ''
    end
    if options[:no_params]  # don't show parentheses.
      params = ''
    end

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
    previous = active_stack.pop
    if active_stack.last == previous
      puts '%s[1]:_' % [active_stack.last.identifier]
    end
  end

end

def start_with(obj) # :yield:
  puts ' '
  Model.push_active_object(obj)
  yield
  Model.pop_active_object
end

def line(message, options = {})
  message.gsub!(/([.:])/) { '\\' + $1 }
  puts "#!" + options[:css] if options[:css]
  puts '%s:%s' % [Model.get_active_object.identifier, message]
  puts "#!" if options[:css]
end

def note(message, options = {})
  right_of = (options[:right_of] || Model.get_active_object).identifier
  attach_to = options[:attach_to] ? options[:attach_to] : 1000
  puts "*%s %s" % [attach_to, right_of]
  puts message
  puts "*%s" % [attach_to]
end

def fragment(type, text = nil) # :yield:
  puts '[c:%s %s]' % [type, text]
  yield
  puts '[/c]'
end

# A separator cannot appear imediately after a fragment(). Use "line ''" to solve this.
def separator(text)
  puts '--%s' % text
end

#def pop_levels(n)
#  puts '%s[%d]:_' % [Model.get_active_object.identifier, n]
#end
