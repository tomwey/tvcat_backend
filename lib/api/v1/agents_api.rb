module API
  module V1
    class AgentsAPI < Grape::API
      
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
        
        desc "获取代理商首页信息"
        params do
          requires :token, type: String, desc: 'TOKEN'
        end
        get :home do
          agent = authenticate_agent!
          
          @orders = Order.where(opened: true, agent_id: agent.uniq_id).order('created_at desc').limit(10)
          
          { code: 0, message: 'ok', data: {
            agent: API::V1::Entities::Agent.represent(agent),
            app_info: {},
            orders: API::V1::Entities::Order.represent(@orders)
          } }
          
        end # end get me 
        
      end # end resource agent
      
    end
  end
end