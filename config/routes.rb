Rails.application.routes.draw do
  get 'historic/record'

  get 'historic/complete'

  get 'planning', to: 'planning#record'
  post 'planning', to: 'planning#complete'
  
  get 'historic', to: 'historic#record'
  post 'historic', to: 'historic#complete'

  get 'registration', to: 'registration#record'
  post 'registration/coordinator_record'
  post 'registration/professor_record'
  post 'registration/student_record'
  
  devise_for :users
  
  resources :coordinators
  
  get 'painel' => 'painel#index'
  
  resource :students, only: [:new, :edit, :create, :update]
  resources :professor_users
  get 'professor_users/new/access', to: 'professor_users#new_access'
  post 'professor_users/create_access'
  post '/professor_users/:id' => 'professor_users#approved'
  post '/professor_users/:id' => 'professor_users#disapproved'
  
  resources :pre_enrollments
  get '/pre_enrollments/:id/result' => 'pre_enrollments#result', as: :pre_enrollments_result
  get '/pre_enrollments/:id/detail' => 'pre_enrollments#detail', as: :pre_enrollments_detail
  
  resources :record_enrollments, path_names: {new: 'new/:pre_enrollment_id' }
  
  resources :semesters, only: [:index, :edit, :update]
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

=begin
  root 'application#updating'
  get '*path' => redirect('/')
=end

  root 'areas#index'

  get 'contato' => 'application#contact', :as => 'contact_us'
  post 'contato' => 'application#send_contact', :as => 'send_contact'

  get 'area/:id' => 'areas#show', :as => 'area'

  get 'curso/:code' => 'courses#show', :as => 'course_page'

  get 'disciplinas/buscar' => 'disciplines#ajax_search', :as => 'discipline_ajax_search'
  get 'disciplinas/' => 'disciplines#get_information', :as => 'discipline_get_information'

  get 'exportar_grade' => 'application#export_schedule_pdf', :as => 'export_schedule_pdf'

  get 'admin' => 'admin#index'
  get 'crawl_courses' => 'admin#crawl_courses', :as => 'crawl_courses'
  get 'crawl_areas' => 'admin#crawl_areas', :as => 'crawl_areas'
  get 'crawl_disciplines' => 'admin#crawl_disciplines', :as => 'crawl_disciplines'
  get 'crawl_pre_reqs' => 'admin#crawl_pre_reqs', :as => 'crawl_pre_reqs'
  get 'crawl_classes' => 'admin#crawl_classes', :as => 'crawl_classes'
  get 'titleize' => 'admin#titleize', :as => 'titleize'
  get 'clear_db' => 'admin#clear_db', :as => 'clear_db'
end
