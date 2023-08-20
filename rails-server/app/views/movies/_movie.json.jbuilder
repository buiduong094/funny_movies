json.extract! movie, :id, :title, :description, :url_share, :youtube_id, :user_email, :info, :created_at, :updated_at
json.url movie_url(movie, format: :json)
