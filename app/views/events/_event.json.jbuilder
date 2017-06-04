json.extract! event, :id, :published, :actor, :verb, :title, :content, :object, :target, :provider, :generator, :created_at, :updated_at
json.url event_url(event, format: :json)
