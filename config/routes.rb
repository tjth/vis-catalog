Rails.application.routes.draw do
  resources :comments

  get 'timeslots/test'

  get '/visualisations/:visid/vote' => 'visualisations#vote'

  get '/visualisations/get_all' => 'visualisations#get_all'

  root to: 'visitors#index'
  devise_for :users, :token_authentication_key => 'authentication_key'

  get '/users/info' => 'users#info' #must be before resources users to avoid route clash

  resources :users

  post '/visualisations' => 'visualisations#create'

  patch '/visualisations/:visid/approve' => 'visualisations#approve'

  get '/users/:userid/makeadmin' => 'users#make_admin'
  
  delete '/visualisations/:visid/reject' => 'visualisations#reject'

  post '/timeslots/copy_from_last_week' => 'timeslots#copy_from_last_week'

  post '/tokens' => 'tokens#create'  

  get '/visualisations/current/:screennum' => 'visualisations#current'

  get '/playout_sessions/info' => 'playout_sessions#get_info'

  get '/visualisations/:visid/render_vis' => 'visualisations#render_vis'

  post '/users/register' => 'users#register'

  get '/timeslots/:id/get_summary' => 'timeslots#get_summary'

  resources :programmes
  resources :visualisations
  resources :timeslots


  get '/schedulingtest/' => 'timeslots#test'

end
