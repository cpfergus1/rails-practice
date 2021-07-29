Rails.application.routes.draw do
  resources :microposts
  resources :users do
    resources :microposts
  end
  root 'users#index'
end
