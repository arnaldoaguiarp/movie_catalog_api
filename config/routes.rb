Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :movies, only: %i[index create] do
        collection do
          post :import
        end
      end
    end
  end
end
