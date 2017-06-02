json.extract! user, :id, :avatar, :name, :email, :deleted_at, :created_at, :updated_at
json.url user_url(user, format: :json)
