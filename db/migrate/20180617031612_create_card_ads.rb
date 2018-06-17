class CreateCardAds < ActiveRecord::Migration
  def change
    create_table :card_ads do |t|
      t.integer :uniq_id
      t.string :title, null: false
      t.string :cover, null: false
      t.integer :active_count, default: 0
      t.boolean :opened, default: true
      t.timestamps null: false
    end
    add_index :card_ads, :uniq_id, unique: true
  end
end
