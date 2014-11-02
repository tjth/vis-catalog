Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :visualisations

  get '/visualisations' => 'visualisations#index' 
  
  get '/visualisations/:visid' => 'visualisations#show'

  delete '/visualisations/:visid' => 'visualisations#delete'
end
