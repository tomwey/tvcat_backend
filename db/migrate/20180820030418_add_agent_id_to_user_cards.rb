class AddAgentIdToUserCards < ActiveRecord::Migration
  def change
    add_column :user_cards, :agent_id, :integer
    add_index :user_cards, :agent_id
  end
end
