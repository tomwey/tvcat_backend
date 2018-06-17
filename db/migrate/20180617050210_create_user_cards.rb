class CreateUserCards < ActiveRecord::Migration
  def change
    create_table :user_cards do |t|
      t.integer :uniq_id
      t.integer :user_id
      t.integer :card_ad_id, null: false
      t.integer :order_id, null: false
      t.datetime :used_at
      t.boolean :opened, default: true

      t.timestamps null: false
    end
    add_index :user_cards, :uniq_id, unique: true
    add_index :user_cards, :user_id
    add_index :user_cards, :card_ad_id
    add_index :user_cards, :order_id
  end
end
