ActiveAdmin.register VipcardTheme do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :owner_id, :cover, :title, :qrcode_watermark_pos, :qrcode_watermark_config, :text_watermark_pos, :text_watermark_config, :opened

index do
  selectable_column
  column '#', :id
  column 'ID', :uniq_id
  column '封面图' do |o|
    image_tag o.cover.url(:small)
  end
  column :title
  column '所有者', :owner_id
  column '二维码位置/二维码设置' do |o|
    raw("#{o.qrcode_watermark_pos}<br>#{o.qrcode_watermark_config}")
  end
  column '文字水印位置/文字水印设置' do |o|
    raw("#{o.text_watermark_pos}<br>#{o.text_watermark_config}")
  end
  column :opened
  column 'at', :created_at
  
  actions
end

form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :cover, hint: '图片尺寸为1080x1600'
    # f.input :owner_id, as: :select, label: '所属用户', collection: User.where(verified: true).map { |user| [user.format_nickname, user.uid] }
    f.input :title, placeholder: '广告描述'
    f.input :opened, label: '启用该广告'
  end
  
  f.inputs '二维码水印设置' do
    f.input :qrcode_watermark_pos, as: :select, label: '二维码位置', collection: VipcardTheme.watermark_pos_data,
      prompt: '-- 选择二维码位置 --', input_html: { style: 'width: 240px;' }
    f.input :qrcode_watermark_config, label: '二维码设置'
  end
  
  f.inputs '文字水印设置' do
    f.input :text_watermark_pos, as: :select, label: '文字水印位置', collection: VipcardTheme.watermark_pos_data,
      prompt: '-- 选择文字水印位置 --', input_html: { style: 'width: 240px;' }
    f.input :text_watermark_config, label: '文字水印设置'
  end
  
  actions
end

end
