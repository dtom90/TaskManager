json.extract! task, :id, :name, :description, :due_date, :completed, :created_at, :updated_at
json.url task_url(task, format: :json)
