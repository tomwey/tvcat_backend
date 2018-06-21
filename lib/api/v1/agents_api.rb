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