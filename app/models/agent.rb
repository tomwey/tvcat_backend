class Agent < ActiveRecord::Base
  has_secure_password
  
  validates :name, :mobile, :login, :level, presence: true
  
  validates :password,
      presence: { on: :create },
      length: { minimum: 6, allow_blank: true }
      
  validate :require_parent
  def require_parent
    if self.level > 0 and self.parent_id.blank?
      errors.add(:parent_id, '必须指定上级代理')
      return false
    end
  end
  
  before_create :generate_uniq_id_and_private_token
  def generate_uniq_id_and_private_token
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
  def self.levels
    # [['L0', 0], ['L1', 1], ['L2', 2]]
    awards = SiteConfig.agent_awards ? SiteConfig.agent_awards.split(',') : []
    
    index = 0
    arr = []
    awards.each do |award|
      arr << ["L#{index}", index]
      index = index + 1
    end
    arr
  end
  
  # 计算佣金
  def calc_earn_for(uc, index, from_agent_id)
    awards = self.agent_awards
    return if awards.empty? or awards.size <= index
    
    ratio = awards[index].to_i
    
    # return 0 if self.level == 0
    
    money = (uc.vip_card_plan.price / 100.0) * (ratio.to_i / 100.0)
    money = (money * 100).to_i
    
    prefix = %w(1 2 3)[index]
    AgentEarn.create!(agent_id: self.uniq_id, 
                      money: money, 
                      title: "#{prefix}级佣金", 
                      ratio: ratio,
                      from_agent_id: from_agent_id,
                      earnable_type: uc.class, 
                      earnable_id: uc.uniq_id)
  end
  
  def agent_awards
    config = self.earn_config
    if config.blank?
      config = SiteConfig.agent_awards
    end
    if config.blank?
      return []
    end
    
    return config.split(',')
  end
  
  def parent
    @parent ||= Agent.find_by(uniq_id: self.parent_id)
  end
  
  def today_earn
    now = Time.zone.now
    
    AgentEarn.where(agent_id: self.uniq_id).where(created_at: now.beginning_of_day..now.end_of_day).pluck(:money).sum
  end
    
  def total_orders
    ids = [self.uniq_id]
    parent = self.parent
    loop do
      break if parent.blank?
      ids << parent.uniq_id
      parent = parent.parent
    end
    
    Order.where(agent_id: ids).count
  end
  
  def child_count
    # child_ids = Agent.where(parent_id: self.uniq_id).pluck(:uniq_id)
    # l0_count = child_ids.size
    index = self.level
    sum = 0
    
    child_ids = [self.uniq_id]
    
    loop do
      if child_ids.empty?
        break
      end
      
      child_ids = Agent.where(parent_id: child_ids).pluck(:uniq_id)
      # puts child_ids
      
      sum += child_ids.size
    end
    
    sum
    
  end
  
  def total_user_cards
    order_ids = Order.where(opened: true, agent_id: self.uniq_id).pluck(:uniq_id)
    UserCard.where.not(used_at: nil).where(order_id: order_ids).count
  end
  
  def today_orders
    now = Time.zone.now
    Order.where(agent_id: self.uniq_id).where(created_at: now.beginning_of_day..now.end_of_day).count
  end
  
end
