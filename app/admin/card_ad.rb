ActiveAdmin.register CardAd do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :cover, :opened
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
  column '#', :id
  column 'ID', :uniq_id
  column '封面图' do |o|
    image_tag o.cover.url(:small)
  end
  column :title
  column :active_count
  column :opened
  column 'at', :created_at
  
  actions
end

end
