require 'csv'
require 'logger'
require 'date'

class CsvImportService
  def initialize(file_content)
    @file_content = file_content
    @logger = Logger.new("#{Rails.root}/log/csv_import.log")
  end

  def import
    imported_count = 0
    already_imported_count = 0
    errors = []

    begin
      # Configuring col_sep and quote_char to handle commas inside quotes
      csv_table = CSV.parse(@file_content, headers: true, col_sep: ',', quote_char: '"')
      csv_table.headers.map!(&:downcase) # Normalizes all headers
      @logger.info("Standardized headers: #{csv_table.headers.inspect}")
    rescue CSV::MalformedCSVError => e
      @logger.error("Error processing CSV: #{e.message}")
      return { imported_count: 0, already_imported_count: 0, errors: ["Error processing CSV file: #{e.message}"] }
    end

    header_mapping = {
      'title' => 'title',
      'release_year' => 'year',
      'country' => 'country',
      'listed_in' => 'genre',
      'date_added' => 'published_at',
      'description' => 'description'
    }

    line_number = 1
    csv_table.each do |row|
      movie_data = prepare_movie_data(row.to_h, header_mapping)
      missing_fields = required_fields_missing(movie_data)

      if missing_fields.any?
        errors << "Line #{line_number}: Invalid record - missing fields: #{missing_fields.join(', ')}"
        line_number += 1
        next
      end

      # Check that the movie already exists before creating a new one
      existing_movie = Movie.find_by(title: movie_data[:title], year: movie_data[:year])

      if existing_movie
        # Increases the count of imported movies
        already_imported_count += 1
        @logger.info("Movie already imported: #{movie_data[:title]} (Year: #{movie_data[:year]})")
      else
        # Creates a new movie and saves it, counting only the new records
        movie = Movie.new(movie_data)
        if movie.save
          imported_count += 1
        else
          errors << "Line #{line_number}: Error saving the movie '#{movie_data[:title]}' - #{movie.errors.full_messages.join(', ')}"
        end
      end
      line_number += 1
    end

    { imported_count: imported_count, already_imported_count: already_imported_count, errors: errors }
  end

  private

  # Maps the CSV data to the Movie template using header_mapping
  def prepare_movie_data(row, mapping)
    movie_data = {}
    mapping.each do |csv_key, model_key|
      # CSV already handles quotes, so there's no need to remove quotes manually
      movie_data[model_key.to_sym] = row[csv_key]&.strip
    end
    # Format the date if present
    movie_data[:published_at] = parse_date(movie_data[:published_at]) if movie_data[:published_at].present?
    movie_data
  end

  # Converts the date string to Date format
  def parse_date(date_string)
    Date.parse(date_string)
  rescue StandardError
    nil
  end

  # Checks for missing mandatory fields
  def required_fields_missing(movie_data)
    missing = []
    missing << 'title' if movie_data[:title].blank?
    missing << 'year' if movie_data[:year].blank?
    missing
  end
end
