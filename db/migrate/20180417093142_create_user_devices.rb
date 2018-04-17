class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.integer :uid
      t.string :uuid,  null: false, default: ''
      t.string :model, null: false, default: ''
      t.string :os,    null: false, default: ''
      t.string :os_version, null: false, default: ''
      t.string :uname # 设备名字，例如：Tomwey的iPhone
      t.string :lang_code

      t.timestamps null: false
    end
    
    add_index :user_devices, :uuid, unique: true
    add_index :user_devices, :uid
    
  end
end
