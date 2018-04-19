require 'rest-client'
module API
  module V1
    class MediaAPI < Grape::API
      
      resource :media, desc: '影视相关接口' do
        
        desc "获取所有的影视提供者"
        params do
          optional :token, type: String, desc: '用户TOKEN'
        end
        get :providers do
          @providers = MediaProvider.opened.sorted.order('id desc')
          render_json(@providers, API::V1::Entities::MediaProvider)
        end # end get
        
        desc "获取播放器"
        params do
          requires :url, type: String, desc: '播放资源地址'
          requires :token, type: String, desc: '用户TOKEN'
        end
        get :player do
          user = authenticate!
          
          if user.vip_expired?
            return render_error(-1, 'VIP已过期')
          end
          
          resp = RestClient.get "#{SiteConfig.player_parse_url}", 
                         { :params => { :url => "#{params[:url]}"
                                      } 
                         }
                     
          result = JSON.parse(resp)
          
          if result.blank?
            { code: 4004, message: '未获取到播放地址' }
          else
            { code: 0, message: 'ok', data: {
              url: result["url"], type: result["type"]
            } }
          end
          
        end # end get player
        
      end # end resource
      
    end
  end
end