# frozen_string_literal: true

Rails.application.routes.draw do
  # Admin
  resources :pages

  # Frontend
  resources :statements, only: %i[index show]
  resources :verifications, only: %i[create]
  resources :reconciliations, only: %i[create]

  match '/api-proxy' => 'media_wiki_api#api_proxy', via: [:get, :post]

  get 'frontend', to: 'general#frontend'
  root 'general#index'
end
