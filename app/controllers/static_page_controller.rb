class StaticPageController < ApplicationController
  def index
    render :layout => 'landing'
  end
end

