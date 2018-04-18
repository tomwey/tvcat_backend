ActiveAdmin.register VipCardTask do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :quantity, :month
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

before_create do |task|
  task.creator = current_admin_user.email
end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :quantity, placeholder: '输入生成的激活卡数量'
    f.input :month, as: :select, collection: VipCard::MONTH_TYPEs, prompt: '-- 选择激活套餐 --'
  end
  actions
end

end
