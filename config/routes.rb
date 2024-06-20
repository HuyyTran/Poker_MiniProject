# frozen_string_literal: true

Rails.application.routes.draw do
  get 'api_pokers/check'
  get 'web_pokers/index'
  get 'web_pokers/check'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'web_pokers#index'

  # Web page
  get '/pokers/index', to: 'web_pokers#index'
  # get '/pokers/show_json', to: 'web_pokers#show_json'
  post '/pokers/check', to: 'web_pokers#check'
  # get '/pokers/result', to: 'web_pokers#result', as: 'pokers_result'

  # API
  post '/pokers/api/v1/cards/check', to: 'api_pokers#check'

  # Unauthorized HTTP methods
  match '*unmatched', to: 'pokers#route_not_found', via: :all
end
