require 'rest-client'

module API
  module V1
    class AppGlobalAPI < Grape::API
            
      resource :app, desc: 'APP相关接口' do
        desc "获取配置数据"
        
        get :config do
          
          hash = {
            explore_url: SiteConfig.app_explore_url,
            kefu_url: SiteConfig.kefu_url,
            aboutus_url: SiteConfig.aboutus_url,
            faq_url: SiteConfig.faq_url,
            download_url: SiteConfig.app_qrcode_url,
            vip_charge_url: SiteConfig.vip_charge_url,
            ad_blacklist: [],
            ad_script: "var $el = $('a[id^=__a_z_]'); $el.hide();var vids = document.getElementsByTagName('video');vids.width=100%;"
          }
          { code: 0, message: 'ok', data: hash }
        end # end get config
        
        desc "版本检查"
        params do
          requires :bv,    type: String, desc: '当前App版本号'
          optional :token, type: String, desc: '用户登录TOKEN'
          optional :m,     type: String, desc: '设备名'
          optional :os,     type: String, desc: '设备平台, ios, android'
          optional :osv,    type: String, desc: '系统版本'
        end
        get :check_version do
          @app_version = AppVersion.where('version > ? and lower(os) = ?', params[:bv], params[:os].downcase)
            .where(opened: true).order('version desc').first
          if @app_version.blank?
            return render_error(4004, '没有新版本')
          end
          
          render_json(@app_version, API::V1::Entities::AppVersion)
        end # end
        
        desc 'IP解析经纬度'
        params do
          requires :ip, type: String, desc: 'IP地址'
        end
        get :location do
          resp = RestClient.get 'http://api.map.baidu.com/location/ip', 
                         { :params => { :ak => "z8cPGX5TKKrZOYbrAlgYcnSYHFm6o5cE",
                                        :ip => params[:ip],
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
          
          { lat: lat, lng: lng }
        end
        
      end # end resource
      
    end
  end
end