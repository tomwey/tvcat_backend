class CreateMediaProviders < ActiveRecord::Migration
  def change
    create_table :media_providers do |t|
      t.integer :uniq_id
      t.string :name, null: false, default: ''
      t.string :icon, null: false, default: ''
      t.string :url,  null: false, default: ''
      t.integer :sort, default: 0
      t.boolean :opened, default: true

      t.timestamps null: false
    end
    add_index :media_providers, :uniq_id, unique: true
    add_index :media_providers, :sort
  end
end
