class VipcardTheme < ActiveRecord::Base
  validates :cover, presence: true
  
  mount_uploader :cover, CoverImageUploader
  
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
  
  def self.watermark_pos_data
    [
      ['-- 无 --', nil], 
      ['左上', 'NorthWest'], 
      ['中上', 'North'], 
      ['右上', 'NorthEast'],
      ['左中', 'West'], 
      ['正中', 'Center'], 
      ['右中', 'East'],
      ['左下', 'SouthWest'], 
      ['中下', 'South'], 
      ['右下', 'SouthEast'],
    ]
  end
  
  def watermark_image(qrcode_image, watermark_text = nil)
    watermark_text = watermark_text || '识别二维码下载APP'
    
    img_url = self.cover.url
    
    watermark_image_content = watermark_image_content qrcode_image
    # puts watermark_image_content
    watermark_text_content  = watermark_text_content watermark_text
    # puts watermark_text_content
    if img_url.include? "?"
      spliter = '&'
    else
      spliter = "?"
    end
    
    "#{img_url}#{spliter}watermark/3#{watermark_image_content}#{watermark_text_content}"
  end
  
  private
  def watermark_image_content(image_url)
    return '' if image_url.blank?
    
    "/image/#{Base64.urlsafe_encode64(image_url)}/gravity/#{self.qrcode_watermark_pos}#{self.qrcode_watermark_config}"
  end
  
  def watermark_text_content(text)
    return '' if text.blank?
    
    "/text/#{Base64.urlsafe_encode64(text)}/gravity/#{self.text_watermark_pos}#{self.text_watermark_config}"
  end
end
