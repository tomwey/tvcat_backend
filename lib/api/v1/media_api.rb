require 'rest-client'
module API
  module V1
    class MediaAPI < Grape::API
      
      helpers API::SharedParams
      
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
          requires :mp_id, type: Integer, desc: '资源提供方ID'
        end
        get :player do
          user = authenticate!
          
          if user.vip_expired?
            return render_error(6008, 'VIP已过期')
          end
            
          provider = MediaProvider.find_by(uniq_id: params[:mp_id])
          if provider.blank?
            return { code: 4004, message: '平台不存在' }
          end
          
          history = MediaHistory.where(uid: user.uid, mp_id: provider.uniq_id, source_url: params[:url]).first

          if history.blank?
            history = MediaHistory.create!(uid: user.uid, 
              mp_id: provider.uniq_id, 
              source_url: params[:url], 
              title: "     ", 
              progress: nil)
          end
          
          parse_url = provider.parse_url || SiteConfig.vid_parse_url
          
          dest_url = "#{parse_url}?url=#{params[:url]}"
          { code: 0, message: 'ok', data: {
            url: dest_url, 
            type: 'm3u8',
            src_url: params[:url],
            title: history.title || '',
            success: 'ok',
            progress: (history.try(:progress) || 0).to_s
          } }
                      
        end # end get player
        
        desc "上传播放进度"
        params do
          requires :url, type: String, desc: '播放资源地址'
          requires :token, type: String, desc: '用户TOKEN'
          optional :progress, type: String, desc: '播放进度'
          optional :title, type: String, desc: '视频名称'
        end
        post '/play/progress' do
          user = authenticate!
          
          history = MediaHistory.where(uid: user.uid, source_url: params[:url]).first
          if history.blank?
            return render_error(4004, '未找到观看记录')
          end
          
          history.progress = params[:progress]
          history.title = params[:title]
          history.save!
          
          render_json_no_data
        end # end post play/progress 
        
        desc "获取所有浏览历史"
        params do
          requires :token, type: String, desc: '用户TOKEN'
          use :pagination
        end
        get :histories do
          user = authenticate!
          @histories = MediaHistory.where(uid: user.uid).order('id desc')
          if params[:page]
            @histories = @histories.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@histories, API::V1::Entities::MediaHistory)
        end # end get histories
        
        # desc "保存浏览历史"
        # params do
        #   requires :token, type: String, desc: '用户TOKEN'
        #   requires :mp_id, type: Integer, desc: '资源提供方ID'
        #   requires :title, type: String, desc: '资源名字'
        #   requires :source_url, type: String, desc: '资源地址'
        #   optional :progress, type: String, desc: '观看进度'
        # end
        # post '/history/create' do
        #   user = authenticate!
        #
        #   provider = MediaProvider.find_by(uniq_id: params[:mp_id])
        #   if provider.blank?
        #     return render_error(4004, '资源提供方不存在')
        #   end
        #
        #   has_saved = MediaHistory.where(uid: user.uid, mp_id: provider.uniq_id, source_url: params[:source_url]).count > 0
        #
        #   if not has_saved
        #     MediaHistory.create!(uid: user.uid, mp_id: provider.uniq_id, source_url: params[:source_url], title: params[:title], progress: params[:progress])
        #   end
        #
        #   render_json_no_data
        #
        # end # end post history create
        
      end # end resource
      
    end
  end
end