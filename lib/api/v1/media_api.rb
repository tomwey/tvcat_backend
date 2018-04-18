module API
  module V1
    class MediaAPI < Grape::API
      
      resource :media, desc: '影视相关接口' do
        
        desc "获取所有的影视提供者"
        get :providers do
          @providers = MediaProvider.opened.sorted.order('id desc')
          render_json(@providers, API::V1::Entities::MediaProvider)
        end # end get
        
        desc "获取播放器"
        params do
          requires :url, type: String, desc: '播放资源地址'
        end
        get :player do
          { url: "http://api.baiyug.cn/vip/index.php?url=#{params[:url]}", type: "url" }
        end # end get player
        
      end # end resource
      
    end
  end
end