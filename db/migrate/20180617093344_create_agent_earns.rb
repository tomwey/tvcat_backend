class CreateAgentEarns < ActiveRecord::Migration
  def change
    create_table :agent_earns do |t|
      t.string :uniq_id
      t.integer :agent_id, null: false
      t.integer :money, null: false
      t.string :title
      t.string :earnable_type
      t.integer :earnable_id

      t.timestamps null: false
    end
    add_index :agent_earns, :uniq_id, unique: true
    add_index :agent_earns, :agent_id
    # add_index :agent_earns, :earnable_id
  end
end
