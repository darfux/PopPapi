Rails.application.routes.draw do
  root "main#index"

  get 'main/index'
  get 'repeat/:id', to: "main#repeat"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
