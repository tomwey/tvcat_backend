class VipPlan < ActiveRecord::Base
  validates :name, :days, :_price, presence: true
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def _price=(val)
    if val
      self.price = (val.to_f * 100).to_i
    end
  end
  
  def _price
    if self.price
      self.price / 100.0
    end
  end
end
