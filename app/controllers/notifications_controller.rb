class NotificationsController < ApplicationController
  def edit
    u = User.find_by_id params[:id]
    if u.toggle_confirmation_email(params[:token])
      render action: 'success'
    else
      render action: 'failed'
    end
  end
end
