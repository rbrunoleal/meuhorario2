class AssociationEnrollment < ApplicationRecord
  belongs_to :record_enrollment
  belongs_to :disciplines_enrollment
end
