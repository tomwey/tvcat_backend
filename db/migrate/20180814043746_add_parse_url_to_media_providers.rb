class AddParseUrlToMediaProviders < ActiveRecord::Migration
  def change
    add_column :media_providers, :parse_url, :string
  end
end
