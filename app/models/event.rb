# encoding: utf-8

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
      %i[actor object target generator provider].each do |s|
        i = opts[s]
        if i.present?
          ws << where("#{s}->'id' ? '#{i.id}' and #{s} -> 'type' ? '#{i.class.name}'")
        end
      end

      # Resolve verb
      if opts[:verb].present?
        verb = opts[:verb]
        verb = resolve_verb opts[:object], opts[:verb] if opts[:object].present?
        ws << where(verb: verb)
      end
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
    # parameters: Hash, optional. 指定 event.paramters.
    def create_event(opts = {})
      object = opts[:object]
      event = new
      event.actor = resolve_value object, opts[:actor]
      event.verb = resolve_verb object, opts[:verb]
      event.object = resolve_value object, :self
      event.parameters = resolve_value object, opts[:parameters]
      event.target = resolve_value object, opts[:target]
      event.generator = resolve_value object, opts[:generator]
      event.provider = resolve_value object, opts[:provider]
      event.published = object.updated_at
      event.save
    end

    # Resolve verb like: team.create, todo.assign
    def resolve_verb(object, verb)
      prefix = object.class.name.underscore + '.'
      verb = verb.to_s
      if verb.start_with? prefix
        verb
      else
        prefix + verb
      end
    end

    # Resolve value based on context
    def resolve_value(context, thing)
      value = case thing
              when :self
                context
              when Symbol
                context.send thing
              when Proc
                thing.call(context)
              else
                thing
              end
      if value.respond_to? :as_partial_event
        value.as_partial_event
      else
        value
      end
    end
  end
end
