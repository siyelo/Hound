class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_timezone

  def set_timezone
    if current_user && current_user.timezone
      Time.zone = ActiveSupport::TimeZone.new(current_user.timezone)
    end
  end

end
