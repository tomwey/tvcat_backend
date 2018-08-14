class AddReleaseDateToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :release_date, :date
    add_index :videos, :release_date
  end
end
