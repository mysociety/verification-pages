# frozen_string_literal: true

Rails.application.routes.draw do
  resources :pages

  resources :verifications, only: %i[create] do
    root to: redirect('/'), as: nil
  end

  root 'general#index'
end
