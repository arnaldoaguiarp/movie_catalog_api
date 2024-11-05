require 'swagger_helper'

RSpec.describe 'Movies API', type: :request do
  path '/api/v1/movies' do
    get 'Lista todos os filmes' do
      tags 'Movies'
      produces 'application/json'

      # Filter parameters for partial search
      parameter name: :year, in: :query, schema: { type: :integer }, description: 'Release year (e.g. 2020)'
      parameter name: :genre, in: :query, schema: { type: :string },
                description: 'Genre of the movie (partial search, e.g. “Dram” for “Drama”)'
      parameter name: :country, in: :query, schema: { type: :string },
                description: 'Country of origin of the movie (partial search, e.g. “United” for “United States”)'
      parameter name: :title, in: :query, schema: { type: :string },
                description: 'Movie title (partial search, e.g. “Incep” for “Inception”)'

      response '200', 'Films successfully listed' do
        let(:year) { 2020 }
        let(:genre) { 'Drama' }
        let(:country) { 'United States' }
        let(:title) { 'Incep' }

        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :string, format: :uuid },
            title: { type: :string },
            genre: { type: :string },
            year: { type: :integer },
            country: { type: :string },
            published_at: { type: :string, format: :date },
            description: { type: :string }
          },
          required: %w[id title genre year country published_at description]
        }

        run_test!
      end

      response '400', 'Invalid parameter' do
        let(:title) { '' }
        let(:year) { 'invalid-year' }
        let(:genre) { 'invalid-genre' }
        let(:country) { 'invalid-country' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Invalid parameter' }
               }
        run_test!
      end
    end

    post 'Create a new movie' do
      tags 'Movies'
      consumes 'application/json'
      parameter name: :movie, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          genre: { type: :string },
          year: { type: :integer },
          country: { type: :string },
          published_at: { type: :string, format: :date },
          description: { type: :string }
        },
        required: %w[title genre year country published_at description]
      }

      let(:movie) do
        {
          title: 'Sample Movie',
          genre: 'Drama',
          year: 2020,
          country: 'United States',
          published_at: '2020-01-01',
          description: 'Sample description for testing'
        }
      end

      response '201', 'Successfully created film' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 title: { type: :string },
                 genre: { type: :string },
                 year: { type: :integer },
                 country: { type: :string },
                 published_at: { type: :string, format: :date },
                 description: { type: :string }
               },
               required: %w[id title genre year country published_at description]

        run_test!
      end

      response '422', 'Error processing the request' do
        let(:movie) { { title: nil } }

        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: ['Title can\'t be blank', 'Year must be an integer']
                 }
               }

        run_test!
      end
    end
  end

  path '/api/v1/movies/import' do
    post 'Import movies from a CSV file' do
      tags 'Movies'
      consumes 'multipart/form-data'

      parameter name: :file, in: :formData, schema: { type: :string, format: :binary },
                description: 'CSV file with movie data'

      response '200', 'Successfully imported films' do
        let(:file) do
          fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'netflix_titles.csv'), 'text/csv')
        end

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Successfully imported films' },
                 imported_count: { type: :integer, example: 10 }
               },
               required: %w[message imported_count]

        run_test!
      end

      response '400', 'File not supplied' do
        let(:file) { nil }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'File not supplied' }
               }

        run_test!
      end

      response '422', 'Error processing CSV file' do
        let(:file) do
          fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'invalid_netflix_titles.csv'), 'text/csv')
        end

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Error processing CSV file' },
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: ['Line 1: missing title', 'Line 2: invalid year']
                 }
               },
               required: %w[message errors]

        run_test!
      end
    end
  end
end
