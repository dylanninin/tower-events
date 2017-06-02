json.extract! comment, :id, :text, :commentable_id, :commentable_type, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url comment_url(comment, format: :json)
