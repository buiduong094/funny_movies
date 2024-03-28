require 'net/http'

class MovieService
  def create(url_share, user_email)
    youtube_id = Movie.get_youtube_id_by_url(url_share)
    return if youtube_id.nil?

    movie = Movie.check_duplicate_share(url_share, user_email)
    return movie if movie

    movie = clone_shared_movie(url_share, user_email, youtube_id)
    return movie if movie

    movie = fetch_and_create_movie(url_share, user_email, youtube_id)
    movie
  end

  private

  def clone_shared_movie(url_share, user_email, youtube_id)
    movie = Movie.find_by(url_share: url_share)
    return unless movie

    new_share = movie.dup
    new_share.user_email = user_email
    new_share.save
    new_share
  end

  def fetch_and_create_movie(url_share, user_email, youtube_id)
    response = fetch_youtube_data(youtube_id)
    return unless response

    json_data = JSON.parse(response.body)
    title = json_data["items"][0]["snippet"]["title"]
    description = json_data["items"][0]["snippet"]["description"]

    Movie.create(
      url_share: url_share,
      youtube_id: youtube_id,
      title: title,
      description: description,
      user_email: user_email,
      info: response.body
    )
  rescue StandardError => e
    # Handle invalid YouTube video
    puts "Error creating movie: #{e.message}"
    nil
  end

  def fetch_youtube_data(youtube_id)
    uri = URI("https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=#{youtube_id}&key=#{ENV['YOUTUBE_API_KEY']}")
    Net::HTTP.get_response(uri)
  end
end
