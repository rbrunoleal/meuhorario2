class Institute < ApplicationRecord	
  	has_many :departments, dependent: :destroy
  	has_many :courses, :through => :departments
end
