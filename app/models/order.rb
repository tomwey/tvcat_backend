class Order < ActiveRecord::Base
  validates :vip_plan_id, :quantity, :agent_id, presence: true
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
  
  after_create :join_card_create_queue
  def join_card_create_queue
    CreateVipCardJob.perform_later(self.id)
    
    # 计算佣金
  end

  def create_cards!
    left_count = self.quantity - self.sent_count
    
    if left_count <= 0
      return
    end
    
    count = 0
    left_count.times do
      UserCard.create!(order_id: self.uniq_id, card_ad_id: self.card_ads.sample)
      count = count + 1
    end
    
    self.sent_count = count
    self.save!
    
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.card_ads = self.card_ads.compact.reject(&:blank?)
  end
  
  def vip_plan
    @vip_plan ||= VipPlan.find_by(uniq_id: self.vip_plan_id)
  end
  
  def agent
    @agent ||= Agent.find_by(uniq_id: self.agent_id)
  end
  
  def total_money
    self[:total_money] || (self.quantity * vip_plan.price)
  end
  
  def agent_earn
    return 0 if agent.level == 0
    
    rate = SiteConfig.send("L#{agent.level}_earn")
    money = (total_money / 100.0) * (rate.to_i / 100.0)
    (money * 100).to_i
  end
  
end
