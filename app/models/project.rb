class Project < ActiveRecord::Base
  validates :name, :bundle_id, :task_started_at, :task_count, presence: true
  
  mount_uploader :icon, AvatarUploader
  
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
 
  def download_urls_val=(val)
    if val.present?
      self.download_urls = val.split(',')#.map { |s| s.gsub(/\s+/, '') }
    end
  end
  
  def download_urls_val
    return self.download_urls.join(',') if self.download_urls.present?
    return nil
  end
end
