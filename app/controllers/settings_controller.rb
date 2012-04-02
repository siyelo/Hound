class SettingsController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @resource = current_user
  end

  def update
    @resource = User.find(current_user.id)
    if @resource.update_without_password(params[:user])
      flash[:notice] = "You have successfully updated your settings."
      redirect_to settings_path
    else
      flash[:alert] = "Sorry, we couldn't update your settings."
      render "edit"
    end
  end

  def update_password
    @resource = User.find(current_user.id)
    if @resource.update_with_password(params[:user])
      flash[:notice] = "You have successfully updated your password."
      sign_in :user, @resource, :bypass => true
      redirect_to settings_path
    else
      flash[:alert] = "Sorry, we couldn't update your password."
      render "edit"
    end
  end
end

