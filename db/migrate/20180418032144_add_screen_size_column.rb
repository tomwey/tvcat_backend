class AddScreenSizeColumn < ActiveRecord::Migration
  def change
    add_column :user_devices, :screen_size, :string
    add_column :user_sessions, :screen_size, :string
    add_column :user_sessions, :uname, :string
  end
end
