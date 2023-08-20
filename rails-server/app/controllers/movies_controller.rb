class MoviesController < ApplicationController
    skip_before_action :authenticate, only: [:index]
    protect_from_forgery unless: -> { request.format.json? }

    before_action :set_movie, only: [:show, :edit, :update, :destroy]
    include HTTParty
  
    # GET /movies
    # GET /movies.json
    def index
      @movies = Movie.all
   #   render :json =>  [{"id":1,"title":"abc","text":"yxaaaa","xxxxxxxxxxxxxxxx":"2023-07-27T11:45:50.129Z","updated_at":"2023-07-27T11:46:06.030Z"}]
    end
  
    # GET /movies/1
    # GET /movies/1.json
    def show
#         # response = HTTParty.get('https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=UkUVl8tFyEo&key=AIzaSyBfeyfvYHAP7CNirf8q0I7TDE8S_aOKU4A',headers: { 
#         #     "Accept" => "application/json",
#         #     'compress' => 'lzw'
#         #   })
#         # curl \
#         # 'https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=UkUVl8tFyEo&key=AIzaSyBfeyfvYHAP7CNirf8q0I7TDE8S_aOKU4A' \
#         # --header 'Accept: application/json' \
#         # --compressed
      
#         # curl \
#         # 'https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=UkUVl8tFyEo&key=[YOUR_API_KEY]' \
#         # --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
#         # --header 'Accept: application/json' \
#         # --compressed
      
#         #api AIzaSyBfeyfvYHAP7CNirf8q0I7TDE8S_aOKU4A


# #        request.body = {} # SOME JSON DATA e.g {msg: 'Why'}.to_json
      
#         response = http.request(request)
      
#         body = JSON.parse(response.body) # e.g {answer: 'because it was there'}
#         puts "body3:"
#         puts body
    end
  
    # GET /movies/new
    def new
      @movie = Movie.new
    end
  
    # GET /movies/1/edit
    def edit
    end
  
    # POST /movies
    # POST /movies.json
    def create
      @movie = movie_service.check_duplicate_share movie_params["url_share"], current_user.email
      duplicated = true;
      if @movie.nil?
        @movie = movie_service.create(movie_params["url_share"], current_user.email)
        duplicated = false;
      end
      respond_to do |format|
        if duplicated
          format.html { redirect_to @movie, notice: 'Movie was duplicated.' }
          format.json { render json: {message: 'Movie was duplicated.'}, status: :unprocessable_entity }
        elsif @movie
          format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
          format.json { render :show, status: :created, location: @movie }
        else
          format.html { render :new }
          format.json { render json: {message: 'Invalid Movie'}, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /movies/1
    # PATCH/PUT /movies/1.json
    def update
      respond_to do |format|
        if @movie.update(movie_params)
          format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
          format.json { render :show, status: :ok, location: @movie }
        else
          format.html { render :edit }
          format.json { render json: @movie.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /movies/1
    # DELETE /movies/1.json
    def destroy
      @movie.destroy
      respond_to do |format|
        format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_movie
        @movie = Movie.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def movie_params
        params.require(:movie).permit(:url_share)
      end

      def movie_service
        @movie_service ||= MovieService.new
      end
  end
  