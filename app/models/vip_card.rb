class VipCard < ActiveRecord::Base
  validates :month, presence: true
  
  MONTH_TYPEs = [
    ['1个月',1],
    ['3个月',3],
    ['半年',6],
    ['1年',12],
    ['2年',24],
  ]
  
  before_create :generate_code
  def generate_code
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.code = n.to_s + SecureRandom.random_number.to_s[2..6]
    end while self.class.exists?(:code => code)
  end
end
