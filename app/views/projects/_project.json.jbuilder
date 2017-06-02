json.extract! project, :id, :name, :description, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url project_url(project, format: :json)
