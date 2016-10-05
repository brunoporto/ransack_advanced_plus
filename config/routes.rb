Rails.application.routes.draw do
  resources :ransack_saved_searches

  namespace :ransack_advanced_plus do
    get 'form_builder/:model', to: 'form_builder#index', as: 'form_builder'
  end

end
