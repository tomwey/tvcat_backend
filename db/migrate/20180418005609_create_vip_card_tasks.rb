class CreateVipCardTasks < ActiveRecord::Migration
  def change
    create_table :vip_card_tasks do |t|
      t.string :uniq_id
      t.integer :quantity, null: false
      t.integer :month,    null: false
      t.string :creator,   null: false

      t.timestamps null: false
    end
    add_index :vip_card_tasks, :uniq_id, unique: true
  end
end
