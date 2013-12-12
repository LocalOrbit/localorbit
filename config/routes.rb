LocalOrbit::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/login" => "devise/sessions#new"
  end

  namespace :admin do
    resources :markets do
      resources :market_managers, as: :managers, path: :managers
    end
  end

  resource :dashboard, controller: "dashboard"

  root to: redirect('/login')
end
