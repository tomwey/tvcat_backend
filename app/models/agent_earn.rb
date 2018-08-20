class AgentEarn < ActiveRecord::Base
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :change_agent_earn
  def change_agent_earn
    if agent
      agent.earn += money
      agent.balance += money
      agent.save!
    end
  end
  
  def from_agent
    @from_agent ||= Agent.find_by(uniq_id: self.from_agent_id)
  end
  
  def product_name
    uc = UserCard.find_by(uniq_id: self.earnable_id)
    if uc && uc.vip_card_plan
      uc.vip_card_plan.name
    else
      ''
    end
  end
  
  def agent
    @agent ||= Agent.find_by(uniq_id: self.agent_id)
  end
end
