module API
  module V1
    class UsersAPI < Grape::API
      
      helpers API::SharedParams
      
      # 用户账号管理
      resource :account, desc: "注册登录接口" do
        desc "APP用户简单注册"
        params do
          requires :uuid,  type: String, desc: '用户设备唯一ID'
          requires :model, type: String, desc: '设备名称'
          requires :os,    type: String, desc: '操作系统'
          requires :osv,   type: String, desc: '系统版本'
          optional :uname, type: String, desc: '设备用户名字'
          optional :lang_code, type: String, desc: '国家语言，例如：zh_CN'
        end
        post :create do
          uuid = params[:uuid]          
          device = UserDevice.find_by(uuid: uuid)
          if device.blank?
            device = UserDevice.new(uuid: uuid, 
                                    model: params[:model], 
                                    os: params[:os], 
                                    os_version: params[:osv],
                                    uname: params[:uname],
                                    lang_code: params[:lang_code]
                                    )
            device.user = User.new
            if device.save
              render_json(device.user, API::V1::Entities::UserBase)
            else
              render_error(4002, '注册失败!')
            end
          else
            render_json(device.user, API::V1::Entities::UserBase)
          end
          
        end # end create
        
        desc "用户注册"
        params do
          requires :mobile,   type: String, desc: "用户手机号"
          requires :password, type: String, desc: "密码"
          requires :code,     type: String, desc: "手机验证码"
          optional :invite_code, type: String, desc: "邀请码，每个用户的invite_code"
        end
        post :signup do
          # 手机号检查
          return render_error(1001, '不正确的手机号') unless check_mobile(params[:mobile])
          
          # 是否已经注册检查
          user = User.find_by(mobile: params[:mobile])
          return render_error(1002, "#{params[:mobile]}已经注册") unless user.blank?
          
          # 密码长度检查
          return render_error(1003, "密码太短，至少为6位") unless params[:password].length >= 6
          
          # 检查验证码是否有效
          auth_code = AuthCode.check_code_for(params[:mobile], params[:code])
          return render_error(2004, '验证码无效') if auth_code.blank?
          
          # 注册
          user = User.create!(mobile: params[:mobile], password: params[:password], password_confirmation: params[:password])
          
          # 激活当前验证码
          auth_code.update_attribute(:activated_at, Time.now)
          
          # 绑定邀请
          inviter = User.find_by(nb_code: params[:invite_code])
          if inviter
            inviter.invite(user)
          end
          
          # 返回注册成功的用户
          render_json(user, API::V1::Entities::User)
        end # end post signup
        
        desc "用户登录"
        params do
          requires :mobile,   type: String, desc: "用户手机号，必须"
          requires :password, type: String, desc: "密码，必须"
        end
        post :login do
          # 手机号检测
          return render_error(1001, "不正确的手机号") unless check_mobile(params[:mobile])
          
          # 登录
          user = User.find_by(mobile: params[:mobile])
          return render_error(1004, "用户#{params[:mobile]}未注册") if user.blank?
          
          if user.authenticate(params[:password])
            render_json(user, API::V1::Entities::User)
          else
            render_error(1005, "登录密码不正确")
          end
        end # end post login
        
        desc "创建微信用户"
        params do
          requires :wx_id, type: String, desc: "微信认证ID"
          optional :wx_avatar, type: String, desc: "微信用户头像Url"
          optional :nickname, type: String, desc: '昵称'
          optional :bio, type: String, desc: '简介'
        end
        post :wx_signup do
          user = User.create!(wx_id: params[:wx_id],
                              wx_avatar: params[:wx_avatar],
                              nickname: params[:nickname], 
                              bio: params[:bio])
          render_json(user, API::V1::Entities::User)
        end # end post wx signup
        
        desc "绑定微信"
        params do
          requires :code, type: String, desc: '微信生成的code'
        end
        post :bind do
          code = WechatAuthCode.where('code = ? and actived_at is null', params[:code]).first
          if code.blank?
            return render_error(-1, '不正确的code')
          end
          
          profile = WechatProfile.find_by(openid: code.wx_id)
          if profile.blank? or profile.user.blank?
            return render_error(-1, '无效的微信用户')
          end
          
          code.actived_at = Time.zone.now
          code.save!
          
          render_json(profile.user, API::V1::Entities::UserBase)
        end # end bind
        
      end # end account resource
      
      resource :user, desc: "用户接口" do
        
        # desc "公开的认证接口"
        # params do
        #   requires :mobile,   type: String, desc: "手机号"
        #   requires :password, type: String, desc: "密码"
        #   optional :mac_addr, type: String, desc: "MAC地址"
        # end
        # get :auth do
        #   # 手机号检测
        #   return render_error(1001, "不正确的手机号") unless check_mobile(params[:mobile])
        #
        #   # 登录
        #   user = User.find_by(mobile: params[:mobile])
        #   return render_error(1004, "用户#{params[:mobile]}未注册") if user.blank?
        #
        #   if user.authenticate(params[:password])
        #     user.update_attribute(:mac_addr, params[:mac_addr]) if user.mac_addr.blank?
        #     render_json(user, API::V1::Entities::User)
        #   else
        #     render_error(1005, "登录密码不正确")
        #   end
        # end # end get auth'
        desc "绑定微信"
        params do
          requires :token, type: String, desc: "用户认证Token"
          requires :wx_id, type: String, desc: "微信认证ID"
        end
        post :wx_bind do
          user = authenticate!
          user.wx_id = params[:wx_id]
          user.save!
          
          render_json(user, API::V1::Entities::User)
        end # end post
        
        desc "获取个人资料"
        params do
          requires :token, type: String, desc: "用户认证Token"
        end
        get :me do
          user = authenticate!
          render_json(user, API::V1::Entities::User)
        end # end get me
        
        desc "修改头像"
        params do
          requires :token,  type: String, desc: "用户认证Token, 必须"
          requires :avatar, type: Rack::Multipart::UploadedFile, desc: "用户头像"
        end
        post :update_avatar do
          user = authenticate!
          
          if params[:avatar]
            user.avatar = params[:avatar]
          end
          
          if user.save
            render_json(user, API::V1::Entities::User)
          else
            render_error(1006, user.errors.full_messages.join(","))
          end
        end # end update_avatar
        
        desc "修改昵称"
        params do
          requires :token,    type: String, desc: "用户认证Token, 必须"
          requires :nickname, type: String, desc: "用户昵称"
        end
        post :update_nickname do
          user = authenticate!
          
          if params[:nickname]
            user.nickname = params[:nickname]
          end
          
          if user.save
            render_json(user, API::V1::Entities::User)
          else
            render_error(1006, user.errors.full_messages.join(","))
          end
        end # end update nickname
        
        desc "修改手机号"
        params do
          requires :token,  type: String, desc: "用户认证Token, 必须"
          requires :mobile, type: String, desc: "新手机号，必须"
          requires :code,   type: String, desc: "新手机号收到的验证码"
        end
        post :update_mobile do
          user = authenticate!
          
          # 手机号检测
          return render_error(1001, "不正确的手机号") unless check_mobile(params[:mobile])
          
          # 检查验证码是否有效
          auth_code = AuthCode.check_code_for(params[:mobile], params[:code])
          return render_error(2004, '验证码无效') if auth_code.blank?
          
          user.mobile = params[:mobile]
          if user.save
            # 激活当前验证码
            auth_code.update_attribute(:activated_at, Time.now)
            
            render_json(user, API::V1::Entities::User)
          else
            render_error(1009, '更新手机号失败！')
          end
          
        end # end post
        
        desc "修改密码"
        params do
          # requires :token,    type: String, desc: "用户认证Token, 必须"
          requires :password, type: String, desc: "新的密码，必须"
          requires :code,     type: String, desc: "手机验证码，必须"
          requires :mobile,   type: String, desc: "手机号，必须"
        end
        post :update_password do
          user = User.find_by(mobile: params[:mobile])
          return render_error(1004, '用户还未注册') if user.blank?
          
          # 检查密码长度
          return render_error(1003, '密码太短，至少为6位') if params[:password].length < 6
          
          # 检查验证码是否有效
          auth_code = AuthCode.check_code_for(user.mobile, params[:code])
          return render_error(2004, '验证码无效') if auth_code.blank?
          
          # 更新密码
          user.password = params[:password]
          user.password_confirmation = user.password
          user.save!
          
          # 激活当前验证码
          auth_code.update_attribute(:activated_at, Time.now)
          
          render_json_no_data
        end # end update password
        
        desc "创建用户会话"
        params do
          requires :token,     type: String,  desc: '用户TOKEN'
          optional :type,      type: Integer, desc: '值为1或2或3；1表示APP Launch, 2表示 APP Resume，3表示 APP Suspend'
          optional :loc,       type: String,  desc: '用户当前位置，值格式为：lng,lat'
          optional :network,   type: String,  desc: '用户当前的网络类型，例如：wifi, 3g, 4g'
          optional :version,   type: String,  desc: '当前客户端的版本号'
          optional :uuid,      type: String,  desc: '设备UUID'
          optional :os,        type: String,  desc: '设备系统'
          optional :osv,       type: String,  desc: '设备系统版本号'
          optional :model,     type: String,  desc: '设备型号，例如：iPhone 5s'
          optional :lang_code, type: String,  desc: '国家语言码，例如：zh_CN'
        end
        post '/session/create' do
          user = authenticate!
          
          if params[:loc]
            loc = "POINT(#{params[:loc].gsub(',', ' ')})"
          else
            loc = nil
          end
          
          UserSession.create!(uid: user.uid, 
                              take_at: Time.zone.now,
                              take_type: (params[:type] || 2).to_i,
                              location: loc,
                              app_version: params[:version],
                              ip: client_ip, 
                              network: params[:network],
                              uuid: params[:uuid],
                              os: params[:os],
                              os_version: params[:osv],
                              model: params[:model],
                              lang_code: params[:lang_code])
            
            
            
          render_json_no_data
        end # end post session/create
        
      end # end user resource
      
    end 
  end
end