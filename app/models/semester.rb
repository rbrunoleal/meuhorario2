class Semester < ApplicationRecord
    
    def current_text
        return self.year + '-' + self.period
    end
end
