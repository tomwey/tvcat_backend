class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :mobile
      t.string :nickname
      t.string :avatar
      t.string :bio
      t.integer :user_session_count, default: 0
      t.datetime :vip_expired_at
      t.string :private_token
      t.boolean :verified, default: true

      t.timestamps null: false
    end
    
    add_index :users, :uid, unique: true
    add_index :users, :mobile, unique: true
    add_index :users, :private_token, unique: true
    
  end
end
