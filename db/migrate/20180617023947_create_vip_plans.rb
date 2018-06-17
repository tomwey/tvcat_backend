class CreateVipPlans < ActiveRecord::Migration
  def change
    create_table :vip_plans do |t|
      t.integer :uniq_id
      t.string :name, null: false
      t.integer :days, null: false

      t.timestamps null: false
    end
    add_index :vip_plans, :uniq_id, unique: true
  end
end
