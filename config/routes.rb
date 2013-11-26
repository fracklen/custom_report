CustomReport::Engine.routes.draw do
  resources :reports do
    member do
      post :remove_all_check_items
      post :toggle_check_item
    end
  end

  root :to => "reports#index"
end
