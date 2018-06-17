class AddSentCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sent_count, :integer, default: 0
  end
end
