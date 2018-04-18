class ChangeColumnsForUserSessions < ActiveRecord::Migration
  def change
    rename_column :user_sessions, :take_at, :begin_time
    add_column :user_sessions, :end_time, :datetime
  end
end
