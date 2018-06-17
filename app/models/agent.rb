class Agent < ActiveRecord::Base
  has_secure_password
  
  validates :name, :mobile, :login, :level, presence: true
  
  validates :password,
      presence: { on: :create },
      length: { minimum: 6, allow_blank: true }
      
  validate :require_parent
  def require_parent
    if self.level > 0
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
    [['L0', 0], ['L1', 1], ['L2', 2]]
  end
  
  def parent
    @parent ||= Agent.find_by(uniq_id: self.parent_id)
  end
  
end
