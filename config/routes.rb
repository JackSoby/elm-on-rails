Rails.application.routes.draw do
  root to: "welcomes#index"
  namespace :api do
      namespace :v1 do
        resources :todos, only: [:index, :create, :destroy]

      end
    end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
