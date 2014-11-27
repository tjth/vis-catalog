Rails.application.routes.draw do
  get 'timeslots/test'

  root to: 'visitors#index'
  devise_for :users, :token_authentication_key => 'authentication_key'
  resources :users

  post '/visualisations' => 'visualisations#create'

  patch '/visualisations/:visid/approve' => 'visualisations#approve'

  get '/users/:userid/makeadmin' => 'users#make_admin'
  
  delete '/visualisations/:visid/reject' => 'visualisations#reject'

  post '/timeslots/copy_from_last_week' => 'timeslots#copy_from_last_week'

  post '/tokens' => 'tokens#create'  

  get '/visualisations/current/:screennum' => 'visualisations#current'

  get '/playout_sessions/info' => 'playout_sessions#get_info'

  resources :programmes
  resources :visualisations
  resources :timeslots


  get '/schedulingtest/' => 'timeslots#test'

end
