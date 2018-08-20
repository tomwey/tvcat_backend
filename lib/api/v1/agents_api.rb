module API
  module V1
    class AgentsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :agent, desc: '代理商相关接口' do
        desc "代理商登录"
        params do
          requires :login, type: String, desc: '账号'
          requires :password, type: String, desc: '密码'
        end
        post :login do
          agent = Agent.find_by(login: params[:login])
          if agent.blank?
            return render_error(1001, '账号不存在')
          end
          
          unless agent.authenticate(params[:password])
            return render_error(1002, '密码不正确')
          end
          
          { code: 0, message: 'ok', data: { token: agent.private_token } }
        end # end login
        
        desc "获取我的下级分销商"
        params do
          requires :token, type: String, desc: 'TOKEN'
        end
        get :children do
          agent = authenticate_agent!
          
          if agent.level == 2
            return render_json([], API::V1::Entities::Agent)
          end
          
          child_ids = [agent.uniq_id]
          tmp = []
          loop do
            if child_ids.empty?
              break
            end
            
            child_ids = Agent.where(verified: true, parent_id: child_ids).pluck(:uniq_id)
            if child_ids.any?
              tmp += child_ids
            end
          end
          
          @agents = Agent.where(uniq_id: tmp).order('id asc')
          
          render_json(@agents, API::V1::Entities::Agent)
          
        end # end get children
        
        desc "获取收益明细"
        params do
          requires :token, type: String, desc: 'TOKEN'
          use :pagination
        end
        get :earns do
          agent = authenticate_agent!
          
          @earns = AgentEarn.where(agent_id: agent.uniq_id).order('id desc')
          if params[:page]
            @earns = @earns.paginate page: params[:page], per_page: page_size
            total = @earns.total_entries
          else
            total = @earns.size
          end
          
          render_json(@earns, API::V1::Entities::AgentEarn, {}, total)
        end # end get
        
        desc "创建代理"
        params do
          requires :token,    type: String, desc: 'TOKEN'
          requires :name,     type: String, desc: '代理人名字'
          requires :mobile,   type: String, desc: '代理人手机'
          requires :login,    type: String, desc: '登录名'
          requires :password, type: String, desc: '密码'
        end
        post :create_child do
          agent = authenticate_agent!
          
          if agent.level == 2
            return render_error(4003, '对不起，3级分销商不能创建下级分销商')
          end
          
          new_agent = Agent.create!(name: params[:name], 
                        mobile: params[:mobile], 
                        level: agent.level + 1, 
                        parent_id: agent.uniq_id,
                        login: params[:login],
                        password: params[:password],
                        password_confirmation: params[:password]
                        )
          render_json(new_agent, API::V1::Entities::Agent)
        end # end post create_child
        
        desc "获取代理商个人信息"
        params do
          requires :token, type: String, desc: 'TOKEN'
        end
        get :me do
          agent = authenticate_agent!
          
          render_json(agent, API::V1::Entities::Agent)
          
        end # end get me
        
        desc "获取代理商首页信息"
        params do
          requires :token, type: String, desc: 'TOKEN'
        end
        get :home do
          agent = authenticate_agent!
          
          # @orders = Order.where(opened: true, agent_id: agent.uniq_id).order('created_at desc').limit(10)
          #
          # { code: 0, message: 'ok', data: {
          #   agent: API::V1::Entities::Agent.represent(agent),
          #   app_info: {},
          #   orders: API::V1::Entities::Order.represent(@orders)
          # } }
          
          render_json(agent, API::V1::Entities::Agent)
          
        end # end get home
        
        desc "获取VIP卡"
        params do
          requires :token, type: String, desc: 'TOKEN'
          requires :state, type: String, desc: 'VIP卡状态，值为pending或sent'
          use :pagination
        end
        get :cards do
          agent = authenticate_agent!
          
          unless %w(pending sent).include? params[:state]
            return render_error(-1, '不正确的state参数')
          end
          
          @order_ids = Order.where(opened: true).where(agent_id: agent.uniq_id).pluck(:uniq_id)
          
          @cards = UserCard.where(order_id: @order_ids, opened: true)
          if params[:state] == 'pending'
            @cards = @cards.where(user_id: nil)
          elsif params[:state] == 'sent'
            @cards = @cards.where.not(user_id: nil)
          end
          
          if params[:page]
            @cards = @cards.paginate page: params[:page], per_page: page_size
            total = @cards.total_entries
          else
            total = @cards.size
          end
          
          render_json(@cards, API::V1::Entities::UserCard, {}, total)
          
        end # get cards 
        
        desc "获取VIP订单"
        params do
          requires :token, type: String, desc: 'TOKEN'
          optional :type,  type: Integer, desc: '获取订单的类型，0表示未发完的，1表示已经发送完毕的订单'
        end
        get :orders do
          agent = authenticate_agent!
          
          @orders = Order.where(opened: true, agent_id: agent.uniq_id).order('id desc')
          type = (params[:type] || 0).to_i
          
          if type == 0
            @orders = @orders.where('quantity > sent_count')
          else
            @orders = @orders.where('quantity <= sent_count')
          end
          
          render_json(@orders, API::V1::Entities::Order)
          
        end # end get orders
        
        desc "发多张卡给用户"
        params do
          requires :token, type: String, desc: 'TOKEN'
          requires :id, type: Integer, desc: '订单ID'
          requires :uids, type: String, desc: '多个用户的ID，用英文逗号分隔'
          optional :need_active, type: Integer, desc: '是否直接激活用户的会员卡, 0表示不激活，1表示激活'
        end
        post :send_cards do
          agent = authenticate_agent!
          
          order = Order.find_by(uniq_id: params[:id])
          if order.blank? or !order.opened
            return render_error(4004, '订单不存在')
          end
          
          if order.quantity <= order.sent_count
            return render_error(3001, '当前订单没有可用的VIP卡')
          end
          
          uids = params[:uids].split(',')
          
          users = User.where(verified: true, uid: uids)
          
          users.each do |user|
            uc = UserCard.create!(order_id: order.uniq_id, 
                                  sent_at: Time.zone.now, 
                                  card_ad_id: order.card_ads.sample, 
                                  user_id: user.uid)
                                  
            if (params[:need_active] || 0).to_i == 1
              uc.used_at = Time.zone.now
              uc.save!
              
              # 更新用户的有效期
              days = order.vip_plan.try(:days) || 0
              if user.vip_expired_at.blank?
                user.vip_expired_at = Time.zone.now + days.days
              else
                if user.vip_expired_at < Time.zone.now
                  user.vip_expired_at = Time.zone.now + days.days
                else
                  user.vip_expired_at = user.vip_expired_at + days.days
                end
              end
    
              user.save!
    
              # 更新广告的激活次数
              if uc.card_ad
                uc.card_ad.active_count = uc.card_ad.active_count + 1
                uc.card_ad.save!
              end
              
            end
          end
          
          render_json(order, API::V1::Entities::Order)
          
        end # end post cards
        
        desc "发卡"
        params do
          requires :token, type: String, desc: 'TOKEN'
          requires :id, type: Integer, desc: 'VIP卡ID'
          requires :uid, type: Integer, desc: '用户ID'
        end
        post :send_card do
          agent = authenticate_agent!
          
          card = UserCard.find_by(uniq_id: params[:id])
          if card.blank? or !card.opened
            return render_error(4004, 'VIP卡不存在')
          end
          
          if card.user_id.present?
            return render_error(2004, '该卡已经被领过了')
          end
          
          user = User.find_by(uid: params[:uid])
          if user.blank?
            return render_error(4004, '用户不存在')
          end
          
          card.user_id = user.uid
          card.sent_at = Time.zone.now
          card.save!
          
          render_json_no_data
          
        end # end post send card
        
      end # end resource agent
      
    end
  end
end