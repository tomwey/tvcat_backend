class UserCard < ActiveRecord::Base
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def card_ad
    @card_ad ||= CardAd.find_by(uniq_id: self.card_ad_id)
  end
  
  def user
    @user ||= User.find_by(uid: self.user_id)
  end
  
  def order
    @order ||= Order.find_by(uniq_id: self.order_id)
  end
  
  def vip_card_plan
    @plan ||= order.try(:vip_plan)
  end
end
