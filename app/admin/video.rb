ActiveAdmin.register Video do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :cover, :body, :sort, :opened, :play_url, :release_date
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
  column('#',:id)
  column 'ID', :uniq_id
  column :title
  column '封面' do |o|
    image_tag o.cover.url(:small)
  end 
  column :play_count
  column :release_date
  column :sort
  column :opened
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :title
    f.input :cover
    f.input :play_url
    f.input :release_date, as: :string, placeholder: '例如：2018-08-03'
    f.input :body, as: :text, input_html: { class: 'redactor' }, placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
    f.input :sort
    f.input :opened
  end
  actions
end

end
