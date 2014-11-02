Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :visualisations

  get '/visualisations/:visid' => 'visualisations#show'

  get '/visualisations/all' => 'visualisations#all' 

  delete '/visualisations/:visid' => 'visualisations#delete'
end
