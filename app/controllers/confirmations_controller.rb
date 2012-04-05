class ConfirmationsController < ApplicationController

  def disable
    u = User.find_by_modify_token(params[:token])
    if u && u.disable_confirmation_emails
      render action: 'success'
    else
      render action: 'failed'
    end
  end
end
