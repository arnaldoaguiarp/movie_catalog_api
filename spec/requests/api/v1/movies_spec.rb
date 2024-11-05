require 'rails_helper'

RSpec.describe 'API::V1::Movies', type: :request do
  let(:headers) { { 'Content-Type': 'application/json' } }

  before do
    FactoryBot.create(:movie, title: 'Titanic', genre: 'Drama', year: 2020, country: 'USA',
                              published_at: '2020-01-01', description: 'Drama movie description')
    FactoryBot.create(:movie, title: 'Interstellar', genre: 'Sci-fi', year: 2021, country: 'Canada',
                              published_at: '2021-06-08', description: 'Sci-fi movie description')
  end

  describe 'GET /api/v1/movies' do
    it 'returns a list of movies with the expected fields' do
      get '/api/v1/movies', headers: headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(2)
      expect(json_response.first.keys).to contain_exactly('id', 'title', 'genre', 'year', 'country', 'published_at',
                                                          'description')
    end

    it 'filters movies by title' do
      get '/api/v1/movies', params: { title: 'Tit' }, headers: headers

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['title']).to eq('Titanic')
    end

    it 'filters movies by year' do
      get '/api/v1/movies', params: { year: 2020 }, headers: headers

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['title']).to eq('Titanic')
      expect(json_response.first['year']).to eq(2020)
    end

    it 'filters movies by exact genre' do
      get '/api/v1/movies', params: { genre: 'Sci-fi' }, headers: headers

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['title']).to eq('Interstellar')
      expect(json_response.first['genre']).to eq('Sci-fi')
    end

    it 'filters movies by country' do
      get '/api/v1/movies', params: { country: 'USA' }, headers: headers

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['title']).to eq('Titanic')
      expect(json_response.first['country']).to eq('USA')
    end

    it 'filters movies by partial genre match' do
      get '/api/v1/movies', params: { genre: 'Dram' }, headers: headers

      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(1)
      expect(json_response.first['genre']).to include('Drama')
    end
  end

  describe 'POST /api/v1/movies' do
    context 'when creating a new movie' do
      let(:valid_params) do
        {
          movie: {
            title: 'New Movie',
            genre: 'Action',
            year: 2022,
            country: 'Brazil',
            published_at: '2022-08-15',
            description: 'An action-packed movie.'
          }
        }
      end

      it 'creates a movie successfully' do
        post '/api/v1/movies', params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('New Movie')
      end

      it 'returns an error when movie already exists' do
        existing_movie = Movie.first
        post '/api/v1/movies', params: { movie: { title: existing_movie.title, year: existing_movie.year } }.to_json,
                               headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Existing movie with the same title and year')
      end

      it 'returns validation errors for invalid data' do
        invalid_params = { movie: { title: '', year: nil } }
        post '/api/v1/movies', params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank", "Year can't be blank")
      end
    end
  end

  describe 'POST /api/v1/movies/import' do
    context 'with a valid CSV file' do
      let(:file) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'netflix_titles.csv'), 'text/csv') }

      it 'imports movies successfully' do
        post '/api/v1/movies/import', params: { file: file }, headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Film import successful')
        expect(json_response['imported_count']).to be > 0
        expect(json_response).to have_key('already_imported_count')
      end

      it 'correctly identifies already imported movies' do
        # First import
        post '/api/v1/movies/import', params: { file: file }, headers: headers
        expect(response).to have_http_status(:ok)

        # Second import - Must identify all as already imported
        post '/api/v1/movies/import', params: { file: file }, headers: headers
        json_response = JSON.parse(response.body)

        expect(json_response['imported_count']).to eq(0)
        expect(json_response['already_imported_count']).to eq(1)
      end
    end

    context 'with a missing file' do
      it 'returns a bad request error when no file is provided' do
        post '/api/v1/movies/import', headers: headers

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('File not supplied')
      end
    end

    context 'with an invalid CSV file' do
      let(:file) do
        fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'invalid_netflix_titles.csv'), 'text/csv')
      end

      it 'returns an error and does not import any records' do
        post '/api/v1/movies/import', params: { file: file }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Import failed. No records were imported.')
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).not_to be_empty

        # Checks that only the movies from the initial setup are present
        expect(Movie.count).to eq(2)
      end
    end
  end
end
