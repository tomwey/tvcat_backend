ActiveAdmin.register Banner do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :image, :link, :opened, :sort


index do
  selectable_column
  column('ID',:uniq_id)
  column :image, sortable: false do |o|
    image_tag o.image.url(:small)
  end
  column :link, sortable: false
  column :opened, sortable: false
  column :sort
  column 'at', :created_at
  
  actions
end

end
