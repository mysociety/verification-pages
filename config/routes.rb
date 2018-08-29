# frozen_string_literal: true

Rails.application.routes.draw do
  # Admin
  resources :countries
  resources :pages do
    collection do
      get :setup
    end

    member do
      post :load
      post :create_wikidata
    end
  end

  # Frontend
  resources :statements, only: %i[index show] do
    collection do
      get 'statistics'
    end
  end
  resources :verifications, only: %i[create]
  resources :reconciliations, only: %i[create]

  match '/api-proxy' => 'media_wiki_api#api_proxy', :via => %i[get post]

  get 'frontend', to: 'general#frontend'
  root 'general#index'
end
