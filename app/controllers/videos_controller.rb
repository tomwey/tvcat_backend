# require 'open-uri'

class VideosController < ApplicationController
  layout 'mobile'
  def index
    @videos = Video.where(opened: true).order('sort desc, release_date desc, play_count desc')
  end
end