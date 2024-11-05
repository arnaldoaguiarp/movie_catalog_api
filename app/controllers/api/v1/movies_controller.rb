module Api
  module V1
    class MoviesController < ApplicationController
      # GET /api/v1/movies
      def index
        # Validation of parameters
        if params[:title].present? && !params[:title].is_a?(String)
          return render json: { error: 'Invalid parameter' }, status: :bad_request
        end

        if params[:year].present? && !valid_year?(params[:year])
          return render json: { error: 'Invalid parameter' }, status: :bad_request
        end

        if params[:genre].present? && !params[:genre].is_a?(String)
          return render json: { error: 'Invalid parameter' }, status: :bad_request
        end

        if params[:country].present? && !params[:country].is_a?(String)
          return render json: { error: 'Invalid parameter' }, status: :bad_request
        end

        # If all the parameters are valid, the search for films continues
        movies = Movie.all

        # Dynamic filters
        movies = movies.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?
        movies = movies.where(year: params[:year]) if params[:year].present?
        movies = movies.where('genre ILIKE ?', "%#{params[:genre]}%") if params[:genre].present?
        movies = movies.where('country ILIKE ?', "%#{params[:country]}%") if params[:country].present?

        # Sorting by release year in descending order
        movies = movies.order(year: :desc)

        # JSON response in the expected format
        render json: movies.as_json(only: %i[id title genre year country published_at description])
      end

      # POST /api/v1/movies
      def create
        # Initializes or finds the record to avoid duplication
        movie = Movie.find_or_initialize_by(title: movie_params[:title], year: movie_params[:year])

        if movie.persisted?
          render json: { error: 'Existing movie with the same title and year' }, status: :unprocessable_entity
        elsif movie.update(movie_params)
          render json: movie.as_json(only: %i[id title genre year country published_at description]), status: :created
        else
          render json: { errors: movie.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def import
        file = params[:file]
        Rails.logger.info "Importing file: #{file.inspect}"

        return render json: { error: 'File not supplied' }, status: :bad_request if file.blank?

        file_content = file.read
        Rails.logger.info "File content: #{file_content.lines.first(5).join}"

        result = CsvImportService.new(file_content).import

        if result[:errors].any?
          Rails.logger.error "Import errors: #{result[:errors].inspect}"
          render json: { message: 'Import failed. No records were imported.', errors: result[:errors] },
                 status: :unprocessable_entity
        else
          Rails.logger.info "Successful import: #{result[:imported_count]} imported films."
          render json: { message: 'Film import successful', imported_count: result[:imported_count] },
                 status: :ok
        end
      end

      private

      def movie_params
        params.require(:movie).permit(:title, :genre, :year, :country, :published_at, :description)
      end

      def valid_year?(year)
        year.to_i.to_s == year && year.to_i.positive?
      end
    end
  end
end
