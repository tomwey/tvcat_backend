class AddJoinCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :join_count, :integer, default: 0
  end
end
