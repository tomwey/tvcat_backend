class CreateUrlParseErrors < ActiveRecord::Migration
  def change
    create_table :url_parse_errors do |t|
      t.integer :uid
      t.string :source_url

      t.timestamps null: false
    end
    add_index :url_parse_errors, :uid
  end
end
