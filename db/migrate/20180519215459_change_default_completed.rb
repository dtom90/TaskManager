class ChangeDefaultCompleted < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:tasks, :completed, false)
  end
end
