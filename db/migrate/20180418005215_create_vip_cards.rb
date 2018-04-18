class CreateVipCards < ActiveRecord::Migration
  def change
    create_table :vip_cards do |t|
      t.string :code
      t.integer :month, null: false
      t.boolean :in_use, default: true
      t.integer :actived_user_id
      t.datetime :actived_at

      t.timestamps null: false
    end
    add_index :vip_cards, :code, unique: true
    add_index :vip_cards, :actived_user_id
  end
end
