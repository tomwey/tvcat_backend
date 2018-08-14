class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :uniq_id
      t.string :title, null: false
      t.string :cover, null: false
      t.text :body
      t.integer :play_count, default: 0
      t.string :play_url, null: false
      t.integer :sort, default: 0
      t.boolean :opened, default: true
      
      t.timestamps null: false
    end
    add_index :videos, :uniq_id, unique: true
    add_index :videos, :sort
    add_index :videos, :play_count
  end
end
