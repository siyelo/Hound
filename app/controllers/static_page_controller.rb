class StaticPageController < ApplicationController
  before_filter :cookies_required, except: [:index]

  def index
    if request.cookies["cookie_test"].blank?
      flash[:notice] = "Warning: Your cookies are disabled."
    end
    render action: :index
  end

  def cookie_test
  end

  private

    def cookies_required
      return unless request.cookies["cookie_test"].blank?

      cookies[:cookie_test] = Time.now
      redirect_to(action: :index)
    end
end

