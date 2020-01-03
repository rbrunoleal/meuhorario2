class Semester < ApplicationRecord
    
    def current_text
        return self.year.to_s + '-' + self.period.to_s
    end
end
