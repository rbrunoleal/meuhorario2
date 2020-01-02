Rails.application.routes.draw do
  #User
  devise_for :users, :skip => 'unlock'
  devise_scope :user do
    get 'users', to: 'users#index'
    delete 'users/:id', to: 'users#destroy', as: :delete_user
    post 'users/lock_user/:id', to: 'users#lock', as: :lock_user
    post 'users/unlock_user/:id', to: 'users#unlock', as: :unlock_user
    post 'users/reset_user/:id', to: 'users#reset', as: :reset_user
  end
  
  #Registration
  get 'registration', to: 'registration#record'
  post 'registration/coordinator_record'
  post 'registration/professor_record'
  post 'registration/student_record'
  
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
  
  #Orientation
  get 'orientation/coordinator' => 'orientation#coordinator'
  get 'orientation/department' => 'orientation#department'
  #Orientation - Resources
  get 'orientation/:professor_id/:course_id/students' => 'orientation#students', as: :orientations
  get 'orientation/:professor_id/:course_id/students/new' => 'orientation#new_student', as: :new_orientation
  get 'orientation/:professor_id/:course_id/students/:orientation_id/edit' => 'orientation#edit_student', as: :edit_orientation
  post 'orientation/:professor_id/:course_id/students' => 'orientation#create_student'
  patch 'orientation/:professor_id/:course_id/students/:orientation_id', :to => 'orientation#update_student', as: :orientation
  put 'orientation/:professor_id/:course_id/students/:orientation_id', :to => 'orientation#update_student'
  delete 'orientation/:professor_id/:course_id/students/:orientation_id', :to => 'orientation#destroy_student'
  #Orientation - Table
  get 'orientation/:professor_id/:course_id/students/table' => 'orientation#table_students', as: :table_orientations
  post 'orientation/:professor_id/:course_id/students/table' => 'orientation#complete_students'
  #Orientation - Student
  get 'orientation/:professor_id/students/:orientation_id/planning', :to => 'orientation#planning_student', as: :planning_orientation
  get 'orientation/:professor_id/students/:orientation_id/historic', :to => 'orientation#historic_student', as: :historic_orientation
  
  
  
  
  
  
  
  
  get 'planning', to: 'planning#record'
  get 'planning/show', to: 'planning#show'
  post 'planning', to: 'planning#complete'
  
  get 'historic', to: 'historic#record'
  get 'historic/show', to: 'historic#show'
  post 'historic', to: 'historic#complete'
  
  #PreEnrollment
  resources :pre_enrollments
  get '/pre_enrollments/:id/result' => 'pre_enrollments#result', as: :pre_enrollments_result

  #RecordEnrollment
  get '/record_enrollments', :to => 'record_enrollments#index', as: :record_enrollments
  get '/record_enrollments/:pre_enrollment_id/new' => 'record_enrollments#new', as: :record_enrollments_new
  post '/record_enrollments' => 'record_enrollments#create'
  get '/record_enrollments/:pre_enrollment_id/:id/edit/' => 'record_enrollments#edit', as: :record_enrollments_edit
  patch '/record_enrollments/:pre_enrollment_id/:id', :to => 'record_enrollments#update', as: :record_enrollment
  put '/record_enrollments/:pre_enrollment_id/:id', :to => 'record_enrollments#update'
  delete '/record_enrollments/:pre_enrollment_id/:id', :to => 'record_enrollments#destroy'

  
  
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
