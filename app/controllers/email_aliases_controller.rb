class EmailAliasesController < ApplicationController
  def create
    @email_alias = EmailAlias.new params[:email_alias]
    @email_alias.user = current_user
    respond_to do |format|
      if @email_alias.save
        flash.now[:notice] = "Your email alias has been successfully created"
      else
        flash.now[:alert] = "Sorry! We couldn't create your email alias"
      end
      format.html { redirect_to edit_user_registration_path }
      format.js
    end
  end

  def destroy
    email_alias = current_user.email_aliases.find_by_id(params[:id])
    if email_alias
      respond_to do |format|
        if email_alias.destroy
          flash.now[:notice] = "Your email alias has been successfully destroyed"
          format.json { render :json => { :success => :true, :data => email_alias } }
        else
          flash.now[:alert] = "Sorry! We couldn't delete your email alias"
        end
        format.html { redirect_to edit_user_registration_path }
      end
    end
  end
end
