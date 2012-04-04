require 'hound/services/user_merger'

class MergeUsersController < ApplicationController
  before_filter :authenticate_user!

  def create
    secondary_user = User.find_and_validate_password(params[:secondary_email],
                                                     params[:secondary_password])
    if secondary_user
      perform_merger(secondary_user)
    else
      flash[:alert] = "Email address not found or password is incorrect"
    end

    redirect_to edit_settings_path
  end

  private

  def perform_merger(secondary_user)
    merger = Hound::UserMerger.new
    if merger.perform(current_user, secondary_user)
      flash[:notice] = "Users successfully merged!"
    else
      flash[:alert] = "Users could not be merged"
    end
  end

end
