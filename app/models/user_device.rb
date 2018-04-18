class UserDevice < ActiveRecord::Base
  def user
    @user ||= User.find_by(uid: self.uid)
  end
end
