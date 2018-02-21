# frozen_string_literal: true

Rails.application.routes.draw do
  resources :statements, only: %i[show]

  resources :pages

  resources :verifications, only: %i[create] do
    root to: redirect('/'), as: nil
  end

  root 'general#index'
end
