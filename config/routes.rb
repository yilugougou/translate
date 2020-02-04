Rails.application.routes.draw do
  resources :translations do
    collection do
      get :get_translate
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
