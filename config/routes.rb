Rails.application.routes.draw do
  
  #User
  devise_for :users, :skip => [:lockable] 
  devise_scope :user do
    get 'users', to: 'users#index'
    delete 'users/:id', to: 'users#destroy', as: :delete_user
    post 'users/lock_user/:id', to: 'users#lock', as: :lock_user
    post 'users/unlock_user/:id', to: 'users#unlock', as: :unlock_user
    post 'users/reset_user/:id', to: 'users#reset', as: :reset_user
  end
  
  #Semester
  resources :semesters, only: [:index, :edit, :update]
  
  #Student
  resources :students, only: [:index, :new, :edit, :create, :update, :destroy]
  
  #Coordinator
  resources :coordinators, only: [:index, :new, :edit, :create, :update, :destroy]
  
  #ProfessorUser
  resources :professor_users, only: [:index, :new, :edit, :create, :update, :destroy]
  get 'professor_users/table' => 'professor_users#table_professors', as: :table_professors
  post 'professor_users/table' => 'professor_users#complete_professors'
  
  
  
  get 'planning', to: 'planning#record'
  get 'planning/show', to: 'planning#show'
  post 'planning', to: 'planning#complete'
  
  get 'historic', to: 'historic#record'
  get 'historic/show', to: 'historic#show'
  post 'historic', to: 'historic#complete'

  get 'registration', to: 'registration#record'
  post 'registration/coordinator_record'
  post 'registration/professor_record'
  post 'registration/student_record'
  
  
  get 'orientation/coordinator' => 'orientation#coordinator'
  #Students
  get 'orientation/:professor_id/students/:orientation_id/planning', :to => 'orientation#planning_student', as: :planning_orientation
  get 'orientation/:professor_id/students/:orientation_id/historic', :to => 'orientation#historic_student', as: :historic_orientation
  
  get 'orientation/:professor_id/students/table' => 'orientation#table_students', as: :many_orientations
  post 'orientation/:professor_id/students/table' => 'orientation#complete_students'
  get 'orientation/:professor_id/students' => 'orientation#students', as: :orientations
  post 'orientation/:professor_id/students' => 'orientation#create_student'
  get 'orientation/:professor_id/students/new' => 'orientation#new_student', as: :new_orientation
  get 'orientation/:professor_id/students/:orientation_id/edit' => 'orientation#edit_student', as: :edit_orientation
  
  patch 'orientation/:professor_id/students/:orientation_id', :to => 'orientation#student_update', as: :orientation
  put 'orientation/:professor_id/students/:orientation_id', :to => 'orientation#student_update'
  delete 'orientation/:professor_id/students/:orientation_id', :to => 'orientation#student_destroy'
  
  
  #PreEnrollment
  resources :pre_enrollments, only: [:index, :destroy]
  get '/pre_enrollments/record' => 'pre_enrollments#record', as: :pre_enrollments_record
  get '/pre_enrollments/:id/edit' => 'pre_enrollments#record', as: :pre_enrollments_edit
  get '/pre_enrollments/:id/result' => 'pre_enrollments#result', as: :pre_enrollments_result
  post 'pre_enrollments', to: 'pre_enrollments#complete'
  
  
  resources :record_enrollments, only: [:index, :destroy]
  get '/record_enrollments/record/:pre_enrollment_id' => 'record_enrollments#record', as: :record_enrollments_record
  get '/record_enrollments/record/:pre_enrollment_id/edit/:id' => 'record_enrollments#record', as: :record_enrollments_edit
  post 'record_enrollments', to: 'record_enrollments#complete'
  
  
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
