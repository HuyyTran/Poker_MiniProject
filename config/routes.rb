Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "pokers#index"

  get "/pokers/index", to: "pokers#index"
  get "/pokers/show_json", to: "pokers#show_json"
  post "/pokers/check", to: "pokers#check"
  get "/pokers/result", to: "pokers#result", as: "pokers_result"
end
