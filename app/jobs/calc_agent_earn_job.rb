class CalcAgentEarnJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(order_id)
    @order = Order.find_by(id: order_id)
    @order.calc_earns
  end
end