class AddFromAgentIdAndRatioToAgentEarns < ActiveRecord::Migration
  def change
    add_column :agent_earns, :from_agent_id, :integer
    add_index :agent_earns, :from_agent_id
    add_column :agent_earns, :ratio, :integer
  end
end
