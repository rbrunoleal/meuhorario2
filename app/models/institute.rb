class Institute < ApplicationRecord
	has_many :institute_departments, dependent: :destroy
  	has_many :departments, :through => :institute_departments

  	has_many :courses, :through => :departments
end
