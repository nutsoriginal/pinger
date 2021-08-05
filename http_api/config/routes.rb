# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :ping do
        resources :statistics, only: %i[index]
        resources :targets, only: %i[create] do
          collection do
            post :remove
          end
        end
      end
    end
  end
end
