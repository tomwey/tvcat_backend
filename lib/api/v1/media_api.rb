module API
  module V1
    class MediaAPI < Grape::API
      
      resource :providers, desc: '影视提供商相关接口' do
        desc "获取所有的影视提供者"
        get do
          @providers = MediaProvider.opened.sorted.order('id desc')
          render_json(@providers, API::V1::Entities::MediaProvider)
        end # end get
        
      end # end resource
      
      resource :media, desc: '媒体相关接口' do
        desc "获取播放器"
        params do
          requires :url, type: String, desc: '播放资源'
        end
        get :player do
          { url: "http://api.baiyug.cn/vip/index.php?url=#{params[:url]}", type: "url" }
        end # end get player
      end # end resource
      
      resource :app, desc: 'APP相关接口' do
        desc "获取配置数据"
        get :config do
          {
            explore_url: '',
            kefu_url: '',
            aboutus_url: '',
            faq_url: '',
          }
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
        
      end # end resource
      
    end
  end
end