json.extract! report, :id, :name, :content, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url report_url(report, format: :json)
