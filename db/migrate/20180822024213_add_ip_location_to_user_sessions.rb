class AddIpLocationToUserSessions < ActiveRecord::Migration
  def change
    add_column :user_sessions, :ip_location, :st_point, geographic: true
    add_index :user_sessions, :ip_location, using: :gist
  end
end
