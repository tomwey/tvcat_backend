# require 'open-uri'

class VideosController < ApplicationController
  layout 'mobile'
  def index
    @videos = Video.where(opened: true).order('sort desc, release_date desc, play_count desc')
  end
  
  def view
    @video = Video.find_by(uniq_id: params[:vid])
    if @video
      @video.play_count += 1
      @video.save
      render text: '1'
    else
      render text: '0'
    end
    
  end
end