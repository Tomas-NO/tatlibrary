Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Defines the root path route ("/")
  # root "articles#index"
  root "home#index"
  get "/home", to: "home#index"
  get "/books", to: "books#index"
  get "/book", to: "book#index"
end
