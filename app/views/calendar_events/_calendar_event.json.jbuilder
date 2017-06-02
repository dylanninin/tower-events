json.extract! calendar_event, :id, :name, :start_date, :end_date, :calendar_id, :calendar_type, :team_id, :creator_id, :deleted_at, :created_at, :updated_at
json.url calendar_event_url(calendar_event, format: :json)
