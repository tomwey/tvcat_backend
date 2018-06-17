class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :uniq_id
      t.integer :vip_plan_id, null: false
      t.integer :quantity, null: false
      t.integer :agent_id, null: false
      t.integer :card_ads, array: true, default: []
      t.integer :total_money
      t.string :creator
      t.boolean :opened, default: true
      
      t.timestamps null: false
    end
    add_index :orders, :uniq_id, unique: true
    add_index :orders, :vip_plan_id
    add_index :orders, :agent_id
  end
end
