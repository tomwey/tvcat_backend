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
  
  after_create :increment_order_sent_count
  def increment_order_sent_count
    if order
      order.sent_count += 1
      order.save!
      
      # 计算佣金
      CalcAgentEarnJob.perform_later(self.id)
    end
  end
  
  # 计算佣金
  def calc_earns
    index = 0
    current_agent = self.agent
    loop do
      break if current_agent.blank?
      
      current_agent.calc_earn_for(self, index, self.agent_id)
      
      index = index + 1
      current_agent = current_agent.parent
    end
  end
  
  def agent
    @agent ||= Agent.find_by(uniq_id: self.agent_id)
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
