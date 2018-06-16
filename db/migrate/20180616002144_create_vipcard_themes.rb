class CreateVipcardThemes < ActiveRecord::Migration
  def change
    create_table :vipcard_themes do |t|
      t.integer :uniq_id
      t.string :title
      t.string :cover, null: false
      t.boolean :opened, default: true
      t.integer :vip_count, default: 0
      t.integer :view_count, default: 0
      t.integer :owner_id
      
      t.string :qrcode_watermark_pos
      t.string :qrcode_watermark_config
      t.string :text_watermark_pos
      t.string :text_watermark_config

      t.timestamps null: false
    end
    add_index :vipcard_themes, :uniq_id
  end
end
