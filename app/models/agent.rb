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
    awards = Agent.agent_awards
    
    index = 0
    arr = []
    awards.each do |award|
      arr << ["L#{index}", index]
      index = index + 1
    end
    arr
  end
  
  # 计算佣金
  def calc_earn_for(order, index)
    awards = Agent.agent_awards
    
    ratio = awards[index].to_i
    
    return 0 if self.level == 0
    
    money = (order.total_money / 100.0) * (ratio.to_i / 100.0)
    money = (money * 100).to_i
    
    prefix = %w(一 二 三)[index]
    AgentEarn.create!(agent_id: self.uniq_id, money: money, title: "#{prefix}级代理佣金", earnable_type: order.class, earnable_id: order.uniq_id)
  end
  
  def self.agent_awards
    SiteConfig.agent_awards ? SiteConfig.agent_awards.split(',') : []
  end
  
  def parent
    @parent ||= Agent.find_by(uniq_id: self.parent_id)
  end
  
end
