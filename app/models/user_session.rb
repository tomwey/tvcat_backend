require 'rest-client'
class UserSession < ActiveRecord::Base
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def parsePoint
    resp = RestClient.get 'http://api.map.baidu.com/location/ip', 
                   { :params => { :ak => "z8cPGX5TKKrZOYbrAlgYcnSYHFm6o5cE",
                                  :ip => client_ip,
                                  :coor => 'bd09ll'
                                } 
                   }
               
    gps_json = JSON.parse(resp)
    
    lat = '0'
    lng = '0'
    
    if gps_json['status'] && gps_json['status'].to_i == 0
      if gps_json['content'] && gps_json['content']['point']
        lat = gps_json['content']['point']['y']
        lng = gps_json['content']['point']['x']
      end
    end
    return "#{lat},#{lng}"
  end
  
end
