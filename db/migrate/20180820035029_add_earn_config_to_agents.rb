class AddEarnConfigToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :earn_config, :string
  end
end
