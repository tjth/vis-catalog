Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :users

  #get '/visualisations' => 'visualisations#index' 
  
  #get '/visualisations/:visid' => 'visualisations#show'

 # delete '/visualisations/:visid' => 'visualisations#delete'

  #get '/visualisations/new' => 'visualisations#create'

  post '/visualisations' => 'visualisations#create'

  patch '/visualisations/approve' => 'visualisations#approve'

  get '/visualisations/moderate' => 'visualisations#moderate'
  resources :visualisations
end
