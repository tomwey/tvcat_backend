class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.integer :uniq_id
      t.string :name
      t.string :mobile
      t.string :login, null: false, default: ''
      t.string :password_digest
      t.string :private_token
      t.boolean :verified, default: true
      t.integer :parent_id          # 父级代理人
      t.integer :level, null: false # 代理级别
      t.integer :earn, default: 0    # 收益，单位为分
      t.integer :balance, default: 0 # 余额，单位为分
      t.timestamps null: false
    end
    add_index :agents, :uniq_id, unique: true
    add_index :agents, :private_token, unique: true
    add_index :agents, :parent_id
  end
end
