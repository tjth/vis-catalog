Rails.application.routes.draw do
  get 'timeslots/test'

  root to: 'visitors#index'
  devise_for :users, :token_authentication_key => 'authentication_key'
  resources :users

  #get '/visualisations' => 'visualisations#index' 
  
  #get '/visualisations/:visid' => 'visualisations#show'

 # delete '/visualisations/:visid' => 'visualisations#delete'

  #get '/visualisations/new' => 'visualisations#create'

  post '/visualisations' => 'visualisations#create'

  patch '/visualisations/:visid/approve' => 'visualisations#approve'

  get '/users/:userid/makeadmin' => 'users#make_admin'
  
  delete '/visualisations/:visid/reject' => 'visualisations#reject'

  post '/timeslots/copy_last_seven' => 'timeslots#copy_last_seven'

  post '/tokens' => 'tokens#create'

  post '/timeslots/submit' => 'timeslots#submit'  

  resources :programmes
  resources :visualisations
  resources :timeslots


  get '/schedulingtest/' => 'timeslots#test'

end
