require 'rest-client'
class UserSession < ActiveRecord::Base
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  after_create :parse_ip_location
  def parse_ip_location
    ParseIPLocJob.perform_later(self.id)
  end
  
  def do_parse_location!
    if self.ip and self.ip_location.blank?
      resp = RestClient.get 'https://apis.map.qq.com/ws/location/v1/ip', 
                     { :params => { :key => "EJZBZ-VCM34-QJ4UU-XUWNV-3G2HJ-DWBNJ",
                                    :ip => self.ip
                                  } 
                     }
      gps_json = JSON.parse(resp)
    
      if gps_json['status'] && gps_json['status'].to_i == 0
        if gps_json['result'] && gps_json['result']['location']
          lat = gps_json['result']['location']['lat']
          lng = gps_json['result']['location']['lng']
          
          self.ip_location = "POINT(#{lng} #{lat})"
          self.save!
        end
      end
    
    end
  end
  
  def user_loc
    loc = self.location || self.ip_location
    [loc.try(:y) || '0', loc.try(:x) || '0']
  end
  
end
