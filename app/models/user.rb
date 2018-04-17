class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
  
  before_create :generate_uid_and_private_token
  def generate_uid_and_private_token
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uid = (n.to_s + SecureRandom.random_number.to_s[2..8]).to_i
    end while self.class.exists?(:uid => uid)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
  def hack_mobile
    return "" if self.mobile.blank?
    hack_mobile = String.new(self.mobile)
    hack_mobile[3..6] = "****"
    hack_mobile
  end
  
  def format_nickname
    text = wechat_profile.try(:nickname) || hack_mobile || self.nickname
    if text.blank?
      text = "ID: #{self.uid}"
    end
    text
  end
  
  def format_avatar_url
    if avatar.present?
      avatar.url(:large)
    else
      ''
    end
  end
  
  
  def block!
    self.verified = false
    self.save!
  end
  
  def unblock!
    self.verified = true
    self.save!
  end
  
end
