class CreateMediaHistories < ActiveRecord::Migration
  def change
    create_table :media_histories do |t|
      t.string :uniq_id
      t.integer :uid
      t.integer :mp_id
      t.string :title, null: false, default: ''
      t.string :source_url, null: false, default: ''
      t.string :progress

      t.timestamps null: false
    end
    add_index :media_histories, :uniq_id, unique: true
    add_index :media_histories, :uid
    add_index :media_histories, :mp_id
  end
end
