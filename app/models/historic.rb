class Historic < ApplicationRecord
  belongs_to :student
  
  has_many :disciplines_historics, dependent: :destroy
end
