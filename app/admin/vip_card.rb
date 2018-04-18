ActiveAdmin.register VipCard do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

permit_params :month, :in_use


form do |f|
  f.semantic_errors
  f.inputs do
    f.input :month, as: :select, collection: VipCard::MONTH_TYPEs, prompt: '-- 选择激活套餐 --'
    f.input :in_use
  end
  actions
end

end
