class CompletedNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :tasks, :completed, false
  end
end
