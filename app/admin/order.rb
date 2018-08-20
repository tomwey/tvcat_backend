ActiveAdmin.register Order do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :vip_plan_id, :quantity, :agent_id, :opened, :total_money, { card_ads: [] }

index do
  selectable_column
  column('#',:id) 
  column :uniq_id
  column 'VIP套餐' do |o|
    raw("#{o.vip_plan.try(:name)}")
  end
  column raw("<br>单价<br>数量<br>总价<br><br>") do |o|
    raw("单价: #{o.vip_plan._price}元/个<br>数量: #{o.quantity}<br>总价: #{'%.2f' % (o.total_money / 100.0) + '元'}")
  end
  column '已发出会员卡', :sent_count
  column '代理商信息' do |o|
    raw("分销商: #{o.agent.name}<br>级别: L#{o.agent.level}")
  end
  
  column :opened
  column 'at', :created_at
  
  actions defaults: false do |o|
    item "查看", admin_order_path(o)
    # if o.quantity > o.join_count
    #   item "生成VIP卡", create_card_admin_order_path(o), method: :put, data: { confirm: '你确定吗?' }
    # end
  end
end

batch_action :create_card, method: :put do |ids|
  batch_action_collection.find(ids).each do |o|
    o.create_cards!
  end
  redirect_to collection_path, alert: "全部生成成功"
end

member_action :create_card, method: :put do
  resource.create_cards!
  redirect_to collection_path, notice: '生成成功'
end

before_create do |order|
  order.creator = current_admin_user.email
end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :vip_plan_id, as: :select, collection: VipPlan.all.map { |a| [a.name, a.uniq_id] }, required: true
    f.input :quantity, placeholder: '大于0'
    f.input :agent_id, as: :select, collection: Agent.where(verified: true).map { |o| ["[#{o.uniq_id}]#{o.name}", o.uniq_id] }, required: true
    f.input :card_ads, as: :check_boxes, collection: CardAd.where(opened: true).map { |o| [o.title, o.uniq_id] }
    f.input :opened
  end
  actions
end

end
