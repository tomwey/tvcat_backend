class CalcAgentEarnJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(id)
    @uc = UserCard.find_by(id: id)
    @uc.calc_earns
  end
end