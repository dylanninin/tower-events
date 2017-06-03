require 'rails_helper'
require 'pry'
require 'pry-nav'

RSpec.describe Todo, type: :model do

  before(:each) do
    User.current = create(:user)
  end

  context 'eventable' do

    it 'create todo' do
      t = create(:todo)

      e = Event.find_by(object: t, verb: 'create').first
      expect(e).not_to be_nil
    end

    it 'destroy todo' do
      t = create(:todo)
      t.destroy

      e = Event.find_by(object: t, verb: 'destroy').first
      # TODO: Destroy todo event
      # expect(e).not_to be_nil
    end

    it 'complete todo' do
      t = create(:todo)
      t.status = :completed
      t.save

      e = Event.find_by(object: t, verb: 'complete').first
      # expect(e).not_to be_nil
    end

    it 'assign todo' do
      t = create(:todo, assignee: nil)
      t.assignee = User.first
      t.save

      e = Event.find_by(object: t, verb: 'assignee').first
      # expect(e).not_to be_nil
    end

    it 'reassign todo' do
      t = create(:todo)
      t.assignee = create(:user)
      t.save

      e = Event.find_by(object: t, verb: 'reassignee').first
      # expect(e).not_to be_nil
    end

    it 'set_due_to todo' do
      t = create(:todo, due_to: nil)
      t.due_to = Date.new
      t.save

      e = Event.find_by(object: t, verb: 'set_due').first
      # expect(e).not_to be_nil
    end

    it 'reply todo' do
      t = create(:todo)

      c = create(:comment, commentable: t)

      e = Event.find_by(object: c, verb: 'reply', target: t).first
      # expect(e).not_to be_nil
    end
  end
end
