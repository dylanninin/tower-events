require 'rails_helper'

RSpec.describe Todo, type: :model do

  before(:each) do
    User.current = create(:user)
  end

  context 'eventable' do

    it 'create' do
      t = create(:todo)

      e = Event.find_by(object: t, verb: 'create').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'destroy' do
      t = create(:todo, deleted_at: nil)
      t.destroy

      e = Event.find_by(object: t, verb: 'destroy').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id

      t = Todo.with_deleted.find(t.id)
      expect(t.deleted?).to be_truthy
    end

    it 'run' do
      t = create(:todo)
      t.status = 'running'
      t.save

      e = Event.find_by(object: t, verb: 'run').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'complete' do
      t = create(:todo)
      t.status = 'completed'
      t.save

      e = Event.find_by(object: t, verb: 'complete').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'reopen' do
      t = create(:todo, status: :completed)
      t.status = 'open'
      t.save

      e = Event.find_by(object: t, verb: 'reopen').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'recover' do
      t = create(:todo, deleted_at: Time.now)
      t.deleted_at = nil
      t.save

      e = Event.find_by(object: t, verb: 'recover').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'assign' do
      old_value, new_value = nil, create(:user)
      t = create(:todo, assignee: old_value)
      t.assignee = new_value
      t.save

      e = Event.find_by(object: t, verb: 'assign').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      audited = { attribute: 'assignee', old_value: nil, new_value: Event.as_partial_event(new_value) }
      expect(e.object['audited']).to eq audited.as_json

      expect(e.target['type']).to eq 'User'
      expect(e.target['id'].to_i).to eq new_value.id

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'reassign' do
      old_value, new_value = create(:user), create(:user)
      t = create(:todo, assignee: old_value)
      t.assignee = new_value
      t.save

      e = Event.find_by(object: t, verb: 'reassign').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      audited = { attribute: 'assignee', old_value: Event.as_partial_event(old_value), new_value: Event.as_partial_event(new_value) }
      expect(e.object['audited']).to eq audited.as_json

      expect(e.target['type']).to eq 'User'
      expect(e.target['id'].to_i).to eq new_value.id

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'set_due_to' do
      old_value, new_value = nil, Date.today
      t = create(:todo, due_to: old_value)
      t.due_to = new_value
      t.save

      e = Event.find_by(object: t, verb: 'set_due_to').first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Todo'
      expect(e.object['id'].to_i).to eq t.id

      audited = { attribute: 'due_to', old_value: old_value, new_value: new_value }
      expect(e.object['audited']).to eq audited.as_json

      expect(e.target).to be_nil

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end

    it 'reply' do
      t = create(:todo)

      c = create(:comment, commentable: t, team: t.team)

      e = Event.find_by(object: c, verb: 'reply', target: t).first
      expect(e).not_to be_nil

      expect(e.actor['id'].to_i).to eq User.current.id
      expect(e.actor['type']).to eq 'User'

      expect(e.object['type']).to eq 'Comment'
      expect(e.object['id'].to_i).to eq c.id

      expect(e.target['type']).to eq 'Todo'
      expect(e.target['id'].to_i).to eq t.id

      expect(e.generator['type']).to eq 'Team'
      expect(e.generator['id'].to_i).to eq t.team_id

      expect(e.provider['type']).to eq 'Project'
      expect(e.provider['id'].to_i).to eq t.project.id
    end
  end
end
