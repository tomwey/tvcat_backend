class AddSentAtToUserCards < ActiveRecord::Migration
  def change
    add_column :user_cards, :sent_at, :datetime
  end
end
