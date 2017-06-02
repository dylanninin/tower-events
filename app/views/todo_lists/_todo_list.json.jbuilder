json.extract! todo_list, :id, :name, :status, :project_id, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url todo_list_url(todo_list, format: :json)
