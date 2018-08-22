class ParseIPLocJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(id)
    @uc = UserSession.find_by(id: id)
    @uc.do_parse_location!
  end
end