class Planning < ApplicationRecord
  belongs_to :student
  has_many :disciplines_plannings, dependent: :destroy
end
