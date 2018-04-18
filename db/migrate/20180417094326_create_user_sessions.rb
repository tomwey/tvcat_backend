class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer :uid
      t.string :uniq_id
      t.datetime :begin_time
      t.datetime :end_time
      t.integer :take_type
      t.st_point :location, geographic: true
      t.string :app_version
      t.string :ip
      t.string :network
      
      t.string :uuid
      t.string :os
      t.string :os_version
      t.string :model
      t.string :lang_code
      

      t.timestamps null: false
    end
    add_index :user_sessions, :uid
    add_index :user_sessions, :uniq_id, unique: true
    add_index :user_sessions, :location, using: :gist
  end
end
