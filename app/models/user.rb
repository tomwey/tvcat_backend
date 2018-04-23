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
    @ud ||= UserDevice.where(uid: self.uid).first
    return @ud.try(:uname) || "ID:#{self.uid}"
  end
  
  def format_avatar_url
    if avatar.present?
      avatar.url(:large)
    else
      ''
    end
  end
  
  def left_days
    if self.vip_expired_at.blank?
      '成为会员'
    elsif self.vip_expired_at < Time.zone.now
      seconds = (Time.zone.now - self.vip_expired_at).to_i
      "过期#{(seconds.to_f / (24 * 3600) + 1).to_i}天"
    else
      seconds = (self.vip_expired_at - Time.zone.now).to_i
      "还剩#{(seconds.to_f / (24 * 3600) + 1).to_i}天到期"
    end
  end
  
  def vip_expired?
    return (self.vip_expired_at.blank? or self.vip_expired_at < Time.zone.now)
  end
  
  def active_vip_card!(card)
    count = card.month
    
    time = self.vip_expired_at || Time.zone.now
    self.vip_expired_at = time + count.month
    self.save!
    
    card.actived_user_id = self.uid
    card.actived_at = Time.zone.now
    card.save!
    
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
