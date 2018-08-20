ActiveAdmin.register Agent do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :mobile, :level, :login, :password, :password_confirmation, :parent_id, :verified, :earn_config

index do
  selectable_column
  column('#',:id)
  column 'ID', :uniq_id
  column raw('<br>名字<br>手机<br>账号<br><br>') do |o|
    raw("名字: #{o.name}<br>账号: #{o.login}<br>手机: #{o.mobile}")
  end
  column raw('<br>代理级别<br>佣金收入<br>账户余额<br><br>') do |o|
    raw("代理级别: L#{o.level}<br>佣金收入: #{'%.2f' % (o.earn / 100.0) + '元'}<br>账户余额: #{'%.2f' % (o.balance / 100.0) + '元'}")
  end
  column '上级代理' do |o|
    if o.parent_id.blank?
      '--'
    else
      link_to "[#{o.parent.uniq_id}]#{o.parent.name}", [:admin, o.parent]
    end
  end
  column :private_token
  column :verified
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :name
    f.input :mobile
    f.input :level, as: :select, collection: Agent.levels
    f.input :parent_id, as: :select, label: '上级代理', collection: Agent.where(verified: true).map { |a| [a.name, a.uniq_id] }
    f.input :earn_config, label: '佣金提成配置', placeholder: '例如：40,20,10', hint: '如果不设置，默认会使用全局配置'
    f.input :verified
  end
  f.inputs "登录信息" do
    f.input :login, placeholder: '需要保证唯一'
    f.input :password, label: '密码'
    f.input :password_confirmation, label: '确认密码'
  end
  actions
end

end
