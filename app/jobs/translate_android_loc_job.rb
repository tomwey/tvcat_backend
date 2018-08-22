class TranslateAndroidLocJob < ActiveJob::Base
  queue_as :scheduled_jobs
  
  def perform(id)
    @uc = UserSession.find_by(id: id)
    @uc.do_translate_android_loc
  end
end