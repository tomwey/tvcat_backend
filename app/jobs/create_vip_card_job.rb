class CreateVipCardJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(id)
    @order = Order.find_by(id: id)
    @order.create_cards!
  end
end