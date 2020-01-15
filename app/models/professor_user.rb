class ProfessorUser < ApplicationRecord
  before_save :downcase_username
  
  belongs_to :user, optional: true
  belongs_to :department
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :username, presence: { message: "Insira o Usuário." }
  
  validates :username, uniqueness: { message: "Usuário já cadastrado." }
  
  has_many :orientations, dependent: :destroy
  
  def record_active
      @record = Coordinator.find_by(username: self.username)
      if(@record)
        return @record.user.present?
      else
        return self.user.present?
      end
  end
  
  private
    def downcase_username
      self.username = self.username.downcase
    end
end
