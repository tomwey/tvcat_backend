class AddPriceToVipPlans < ActiveRecord::Migration
  def change
    add_column :vip_plans, :price, :integer
  end
end
