class UserCard < ActiveRecord::Base
  def card_ad
    @card_ad ||= CardAd.find_by(uniq_id: self.card_ad_id)
  end
  
  def order
    @order ||= Order.find_by(uniq_id: self.order_id)
  end
  
  def vip_card_plan
    @plan ||= order.try(:vip_plan)
  end
end
