require 'open-uri'

class HomeController < ApplicationController
  def error_404
    render text: 'Not found', status: 404, layout: false
  end
    
  def download
    @page = Page.find_by(slug: 'app_download')
    @page_title = @page.title
    
    if request.from_smartphone?
      if request.os == 'Android'
        @app_url = "#{app_install_url}"
      elsif request.os == 'iPhone'
        version = AppVersion.where('lower(os) = ?', 'ios').where(opened: true).order('version desc').first
        @app_url = version.try(:app_url) || "#{app_download_url}"
      else
        @app_url = "#{app_download_url}"
      end
    else
      @app_url = "#{app_download_url}"
    end
    
  end
    
  def install
    ua = request.user_agent
    is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
    
    if is_wx_browser
      # render :hack_download
      File.open("#{Rails.root}/config/hack.doc", 'r') do |f|
        send_data f.read, disposition: 'attachment', filename: 'file.doc', stream: 'true'
      end
    else
      if request.from_smartphone? and request.os == 'Android'
        version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
        redirect_to version.app_url || "#{app_download_url}"
      else
        redirect_to "#{app_download_url}"
      end
    end
  end
  
  def parse_error
    url   = params[:url]
    token = params[:token]
    
    UrlParseError.create(source_url: url, uid: User.find_by(private_token: token).try(:uid))
  end
  
  def user_cards
    @user = User.find_by(uid: params[:uid])
    if @user.blank?
      render text: '用户不存在', status: 404, layout: false
      return
    end
    
    @cards = UserCard.where(user_id: @user.uid).order('sent_at desc, id desc')
  end
  
  def use_card
    @user = User.find_by(uid: params[:uid])
    if @user.blank?
      render text: '用户不存在'
      return
    end
    
    card = UserCard.where(user_id: @user.uid, uniq_id: params[:id]).first
    if card.blank?
      render text: 'VIP卡不存在'
      return
    end
    
    if card.used_at.present?
      render text: 'VIP卡已经激活'
      return
    end
    
    card.used_at = Time.zone.now
    card.save!
    
    # 更新用户的有效期
    days = card.vip_card_plan.try(:days) || 0
    if @user.vip_expired_at.blank?
      @user.vip_expired_at = Time.zone.now + days.days
    else
      @user.vip_expired_at = @user.vip_expired_at + days.days
    end
    
    @user.save!
    
    # 更新广告的激活次数
    if card.card_ad
      card.card_ad.active_count = card.card_ad.active_count + 1
      card.card_ad.save!
    end
    
    render text: '1'
  end
  
end