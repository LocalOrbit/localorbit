LocalOrbit::Application.routes.draw do

  devise_for :users
  devise_scope :user do
    get "/login" => "devise/sessions#new"
  end

  namespace :admin do
    resources :markets do
      resources :market_managers, as: :managers, path: :managers
    end

    resources :organizations do
      resources :users
    end

    resources :products do
      resources :lots
    end
  end

  resource :dashboard, controller: "dashboard"

  root to: redirect('/login')
end
