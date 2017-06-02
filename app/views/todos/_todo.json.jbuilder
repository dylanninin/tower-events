json.extract! todo, :id, :name, :status, :due_to, :assignee_id, :todo_list_id, :project_id, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url todo_url(todo, format: :json)
