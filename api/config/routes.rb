Rails.application.routes.draw do
  get 'health', to: 'health#index'
  post 'questions', to: 'questions#create'
end
