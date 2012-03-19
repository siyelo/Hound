class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_timezone, if: :current_user_with_timezone?
  after_filter :reset_timezone, if: :current_user_with_timezone?

  protected

  def set_timezone
    Time.zone = current_user.timezone
  end

  def reset_timezone
    Time.zone = Hound::Application.config.time_zone
  end

  def current_user_with_timezone?
    current_user && current_user.timezone
  end

end
