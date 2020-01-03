class DisciplineCode < ApplicationRecord
    validates :from_code, presence: { message: "Insira o Código(DE)." }
    validates :to_code, presence: { message: "Insira o Código(PARA)." }
end
