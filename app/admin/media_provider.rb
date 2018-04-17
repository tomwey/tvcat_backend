ActiveAdmin.register MediaProvider do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :icon, :url, :sort, :opened

index do
  selectable_column
  column('ID',:uniq_id)
  column :icon, sortable: false do |o|
    image_tag o.icon.url(:large), size: '36x36'
  end
  column :name, sortable: false
  column :url, sortable: false
  column :opened, sortable: false
  column :sort
  column 'at', :created_at
  
  actions
end

end
