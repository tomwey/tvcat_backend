class Packet < ActiveRecord::Base
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
  
  def device_info
    @device_info ||= DeviceInfo.find_by(uniq_id: self.device_info_id)
  end
  
  def board
    device_info.try(:board)
  end
  
  def brand
    device_info.try(:brand)
  end
  
  def cpu
    device_info.try(:cpu)
  end
  
  def cpu2
    device_info.try(:cpu2)
  end
  
  def device
    device_info.try(:device)
  end
  
  def display
    device_info.try(:display)
  end
  
  def fingerprint
    device_info.try(:fingerprint)
  end
  
  def hardware
    device_info.try(:hardware)
  end
  
  def product_model
    device_info.try(:product_model)
  end
  
  def manufacturer
    device_info.try(:manufacturer)
  end
  
  def model
    device_info.try(:model)
  end
  
  def product
    device_info.try(:product)
  end
  
  def bootloader
    device_info.try(:bootloader)
  end
  
  def host
    device_info.try(:host)
  end
  
  def build_tags
    device_info.try(:build_tags)
  end
  
  def incremental
    device_info.try(:incremental)
  end
  
end
