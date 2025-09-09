Rails.application.routes.draw do
  root 'quizzes#index'
  
  resources :quizzes, only: [:index, :show, :new, :create] do
    resources :quiz_attempts, only: [:create]
  end
  
  resources :quiz_attempts, only: [:show, :update] do
    member do
      get :results
    end
  end
end
