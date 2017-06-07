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
      ws << where(verb: opts[:verb]) if opts[:verb].present?
      ws.inject(all, :merge)
    end

    # Create event with opts
    #
    # opts:
    # actor：Object, required. 指定 event.actor, 即当前操作者
    # verb: String, required, 指定 event.verb
    # object: Object, required. 指定 event.object，即当前操作的首要对象
    # target：Object, optional. 指定 event.target，即当前操作的目标对象
    # provider: Object, optional. 指定 event.provider, 属于 Context
    # generator: Object, optional. 指定 event.generator, 属于 Context
    # changed_attribute: Hash，因属性取值变化而产生的事件，如修改Todo的完成事件、完成者等
    # => name. 即要跟踪变化的属性.
    # => alias. 属性别名，若不指定默认为 name 取值。例如 name: :assignee_id, alias: :assignee，则在 audited[attribute] = :assignee
    # => old_value?：Proc. 指定数据属性取值变化时，旧的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    # => new_value?：Proc. 指定数据属性取值变化时，新的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    # => value_proc：Proc. 指定 event.object.audited 中 old|new_value 的求值 proc，若不指定默认为原始值
    def create_event(opts = {})
      object = opts[:object]
      event = new
      event.actor = as_partial_event opts[:actor]
      event.verb = opts[:verb]
      event.object = as_partial_event object
      audited = object_attribute_audited(object, opts[:changed_attribute])
      event.object[:audited] = audited if audited.present? && event.object.present?
      event.target = as_partial_event opts[:target]
      event.provider = as_partial_event opts[:provider]
      event.generator = as_partial_event opts[:generator]
      event.published = object.updated_at
      event.save
    end

    # To partial event: json format
    # Object that as partial event should implement method :as_partial_event
    # Or else, all attributes will be serialized
    def as_partial_event(object)
      return nil unless object.present?
      json = object&.as_partial_event || object.as_json
      # TODO: Attribute type should be reserved
      json[:type] = object.class.name
      # FIXME: Convert id to string, for gin index in PostgreSQL
      json[:id] = object.id.to_s
      json
    end

    private

    # Audit object attribute if it has been changed
    # object: the current object being audited
    #
    # opts:
    # name: required. the attribute to be audit
    # alias: optional. the attribute alias name
    # old_value?: optional. proc to check if the old value has satisfied the condition
    # new_value?: optional. proc to check if the new value has satisfied the condition
    # value_proc: optional. proc to re-evaluate the old|new value after it has satisfied the condition
    def object_attribute_audited(object, opts = {})
      return nil unless opts.present?

      attr_name = opts[:name]
      return nil unless attr_name.present?

      change = object.send(:"#{attr_name}_change")
      return nil unless change.present?

      need_audit = true
      %i[old_value? new_value?].each_with_index do |v, i|
        c = opts[v]
        next if c.blank?
        unless c.call(change[i])
          need_audit = false
          break
        end
      end
      return nil unless need_audit

      {
        attribute: opts[:alias] || attr_name,
        old_value: opts[:value_proc] ? as_partial_event(opts[:value_proc].call(change[0])) : change[0],
        new_value: opts[:value_proc] ? as_partial_event(opts[:value_proc].call(change[1])) : change[1]
      }
    end
  end
end
