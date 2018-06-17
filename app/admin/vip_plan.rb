ActiveAdmin.register VipPlan do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :days, :_price
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :name, placeholder: '例如：7天免费送，1个月VIP'
    f.input :days, placeholder: '输入天数', hint: '1个月按30天算，1年按365天算'
    f.input :_price, as: :number, label: '套餐价格', placeholder: '单位为元'
  end
  actions
end

end
