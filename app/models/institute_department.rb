class InstituteDepartment < ApplicationRecord
  belongs_to :institute
  belongs_to :department
end
