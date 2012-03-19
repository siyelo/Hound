class NotificationsController < ApplicationController

  def edit
    u = User.find(params[:id])
    if u.disable_confirmation_emails(params[:token])
      render action: 'success'
    else
      render action: 'failed'
    end
  end
end
