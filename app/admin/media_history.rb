ActiveAdmin.register MediaHistory do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

actions :all, except: [:new, :create, :edit, :update]

# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('ID',:uniq_id)
  column '资源提供者', sortable: false do |o|
    o.provider.blank? ? '' : image_tag(o.provider.icon.url(:large), size: '36x36')
  end
  column '用户', sortable: false do |o|
    o.user.blank? ? '' : link_to(o.user.format_nickname, [:admin, o.user])
  end
  column :title, sortable: false
  column :source_url, sortable: false
  column :progress, sortable: false
  column 'at', :created_at
  
  actions
end

end
