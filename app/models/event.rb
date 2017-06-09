class Event < ApplicationRecord

  class << self
    # Find event by: pass norrmal model object
    # eg:
    # => u, o = User.first, Todo.first
    # => Event.find_by(verb: 'create') # return all `create` events
    # => Event.find_by(verb: 'create', actor: u) # return all `create` events by this actor
    # => Event.find_by(verb: 'create', actor: u, object: o) # return all `create` events about that object by this actor
    # => Event.find_by # return all events, same with Event.all
    def find_by(opts = {})
      ws = []
      %i(actor object target generator provider).each do |s|
        i = opts[s]
        if i.present?
          ws << where("#{s}->'id' ? '#{i.id}' and #{s} -> 'type' ? '#{i.class.name}'")
        end
      end
      ws << where(verb: opts[:verb]) if opts[:verb].present?
      ws.inject(all, :merge)
    end

    # Create event
    # opts:
    # actor：Object, required. 指定 event.actor, 即当前操作者
    # verb: String, required, 指定 event.verb
    # object: Object, required. 指定 event.object，即当前操作的首要对象
    # target：Object, optional. 指定 event.target，即当前操作的目标对象
    # provider: Object, optional. 指定 event.provider, 属于 Context
    # generator: Object, optional. 指定 event.generator, 属于 Context
    # audited: Hash，因属性取值变化而产生的事件，如修改Todo的完成事件、完成者等
    # => attribute. 即要跟踪变化的属性.
    # => old_value. 指定数据属性旧的取值
    # => new_value. 指定数据属性新的取值
    def create_event(opts = {})
      object = opts[:object]
      event = self.new
      event.actor = resolve_value object, opts[:actor]
      event.verb = opts[:verb]
      event.object = resolve_value object, :self
      event.object[:audited] = opts[:audited] if opts[:audited].present? && event.object.present?
      event.target = resolve_value object, opts[:target]
      event.generator = resolve_value object, opts[:generator]
      event.provider = resolve_value object, opts[:provider]
      event.published = object.updated_at
      event.save
    end

    def resolve_value(context, thing)
      value = nil
      case thing
      when :self
        value = context
      when Symbol
        value = context.send thing
      when Proc
        value = thing.call(context)
      end
      value&.as_partial_event
    end

  end
end
