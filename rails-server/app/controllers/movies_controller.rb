require 'json'
class MoviesController < ApplicationController
    skip_before_action :authenticate, only: [:index]
    protect_from_forgery unless: -> { request.format.json? }

    before_action :set_movie, only: [:show, :edit, :update, :destroy]
    include HTTParty

    # GET /movies
    # GET /movies.json
    def index
      @movies = Movie.all
      movies = @movies.map {
        |movie| movie.as_json(current_user)
      }
      render json: movies
    end

    # GET /movies/1
    # GET /movies/1.json
    def show
    end

    # GET /movies/new
    def new
      @movie = Movie.new
    end

    # GET /movies/1/edit
    def edit
    end

    # POST /moovie
    # POST /movies.json
    def create
      youtube_id = Movie.get_youtube_id_by_url movie_params["url_share"]
      @movie = Movie.check_duplicate_share movie_params["url_share"], current_user.email
      duplicated = @movie.present?
      if @movie.nil? && youtube_id.present?
        @movie = movie_service.create(movie_params["url_share"], current_user.email)
        @movie.send_notification(current_user) if @movie.present?
      end
      respond_to do |format|
        if @movie && !duplicated
          format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
          format.json { render :show, status: :created, location: @movie }
        else
          format.html { render :new }
          message = duplicated ? 'Duplicated Movie' : 'Invalid Movie'
          format.json { render json: {message: message}, status: :unprocessable_entity }
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

    def like
      if(params[:action_type] == 'like') || (params[:action_type] == 'dislike')
        user_movie = UserMovie.new(user_id: current_user.id, movie_id: params[:id], action_type: params[:action_type])
        user_movie.save
        render json: user_movie.movie.as_json(current_user)
      else
        UserMovie.where(user_id: current_user.id, movie_id: params[:id], action_type: params[:action_type].sub!('un','')).first.destroy
        render json: Movie.find(params[:id]).as_json(current_user)
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
