LocalOrbit::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/login" => "devise/sessions#new"
  end

  resource :dashboard, controller: "dashboard"

  root to: redirect('/login')
end
