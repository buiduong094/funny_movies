require "rails_helper"

RSpec.describe MovieService do
  describe "Service" do
    before do
      @movie_service = MovieService.new
      @valid_url = "https://www.youtube.com/watch?v=GEPkkn6JvDU"
      @in_valid_url = "https://www.youtube.com/watch?v=GEPkkn6JvDD"
      @movie = @movie_service.create(@valid_url, "existshare@abc.com.vn")
    end
    
    it 'should create valid movie by user' do
      movie = @movie_service.create(@valid_url, "user@abc.com.vn")
      movie.should be_valid
    end

    it 'should share by multiple user' do
      movie = @movie_service.create(@valid_url, "firstuser@abc.com.vn")
      movie2 = @movie_service.create(@valid_url, "seconduser@abc.com.vn")
      movie2.should be_valid
    end

    it 'should not share by exist_share' do
      exist_share = @movie_service.create(@valid_url, "existshare@abc.com.vn")
      expect(exist_share).to eq(@movie)
    end

    it 'should not share by invalid youtube id' do
      exist_share = @movie_service.create(@in_valid_url, "existshare@abc.com.vn")
      exist_share.should be_nil
    end

    it 'should be valid youtube link' do
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/watch?v=0zM3nApSvMg&feature=feedrec_grec_index")).to eq("0zM3nApSvMg")
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/user/IngridMichaelsonVEVO#p/a/u/1/QdK8U-VIH_o")).to eq("QdK8U-VIH_o")
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/v/0zM3nApSvMg?fs=1&amp;hl=en_US&amp;rel=0")).to eq("0zM3nApSvMg")
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/watch?v=0zM3nApSvMg#t=0m10s")).to eq("0zM3nApSvMg")
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/embed/0zM3nApSvMg?rel=0")).to eq("0zM3nApSvMg")
      expect(@movie_service.get_youtube_id_by_url("http://www.youtube.com/watch?v=0zM3nApSvMg")).to eq("0zM3nApSvMg")
      expect(@movie_service.get_youtube_id_by_url("http://youtu.be/0zM3nApSvMg")).to eq("0zM3nApSvMg")
    end

    it 'should be invalid youtube link' do
      @movie_service.get_youtube_id_by_url("http://www.abccccc.com/?abccc=0zM3nApSvMg&feature=feedrec_grec_index").should be_nil
    end
  end
end
