class Task < ApplicationRecord
  
  def self.retrieve_tasks(overdue, today, tomorrow, completed)
    
    if completed
      return self.where({completed: true})
    end

    if overdue
      overdue_tasks = self.where("due_date < ? AND completed = ?", Date.today, false)
    end
    
    if today or tomorrow
      date_options = []
      date_options << Date.today if today
      date_options << Date.today+1 if tomorrow
      due_tasks = self.where({due_date: date_options, completed: false})
      
      return due_tasks.or(overdue_tasks) if overdue
      return due_tasks
    elsif overdue
      return overdue_tasks
    end
    
    return self.all
    
  end
  
end
