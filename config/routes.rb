# frozen_string_literal: true

Rails.application.routes.draw do
  resources :statements, only: %i[show]

  resources :pages

  resources :verifications, only: %i[create] do
    root to: redirect('/'), as: nil
  end

  match '/api-proxy' => 'media_wiki_api#api_proxy', via: [:get, :post]

  get 'frontend', to: 'general#frontend'
  root 'general#index'
end
