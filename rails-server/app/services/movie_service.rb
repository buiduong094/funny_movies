require 'net/http'

class MovieService

    def create url_share, user_email
        youtube_id = get_youtube_id_by_url url_share
        return if youtube_id.nil?

        # step 1 check record in db
        # movie = Movie.find_by(youtube_id: youtube_id, user_email: user_email)
        movie = check_duplicate_share url_share, user_email
        ## Exist record?
        return movie unless movie.nil?

        ## hande other member shared this movie
        movie = Movie.find_by_url_share youtube_id
        if movie
            new_share = movie.clone
            new_share.user_email = user_email
            return new_share.save
        end

        # step 2 call to youtube api get the detail
        uri = URI('https://youtube.googleapis.com/')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new("https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id="+youtube_id+"&key="+ENV['YOUTUBE_API_KEY'],
            {
                'Accept' => 'application/json',
                'compress' => 'lzw'
            })
        response = http.request(request)

        begin
            title = JSON.parse(response.body)["items"][0]["snippet"]["title"]
            description = JSON.parse(response.body)["items"][0]["snippet"]["description"]
            movie = Movie.new(
                url_share: url_share,
                youtube_id: youtube_id,
                title: title,
                description: description,
                user_email: user_email,
                info: response.body
            )
            movie.save
        rescue => e
            #invalid youtube video
            puts "invalid youtube #{youtube_id}"
            return nil
        end
        return movie
    end

    def check_duplicate_share url_share, user_email
        youtube_id = get_youtube_id_by_url url_share
        return if youtube_id.nil?
        Movie.find_by(youtube_id: youtube_id, user_email: user_email)
    end


    # function get youtube id from url
    # return nil if the url is not valid
    # follow by https://stackoverflow.com/questions/3452546/how-do-i-get-the-youtube-video-id-from-a-url
    #  text/javascript
    #  function youtube_parser(url){
    #     var regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/;
    #     var match = url.match(regExp);
    #     return (match&&match[7].length==11)? match[7] : false;
    #  }
    # Test by data
    # http://www.youtube.com/watch?v=0zM3nApSvMg&feature=feedrec_grec_index
    # http://www.youtube.com/user/IngridMichaelsonVEVO#p/a/u/1/QdK8U-VIH_o => TODO fix if need
    # http://www.youtube.com/v/0zM3nApSvMg?fs=1&amp;hl=en_US&amp;rel=0
    # http://www.youtube.com/watch?v=0zM3nApSvMg#t=0m10s
    # http://www.youtube.com/embed/0zM3nApSvMg?rel=0
    # http://www.youtube.com/watch?v=0zM3nApSvMg
    # http://youtu.be/0zM3nApSvMg
    def get_youtube_id_by_url url_share
        youtube_id =/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/.match(url_share)
        !youtube_id.nil? && !youtube_id[7].nil? && youtube_id[7].length==11? youtube_id[7] : nil
    end
end
