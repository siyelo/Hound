class Users::RegistrationsController < Devise::RegistrationsController
  # override the default Devise user (or 'registration') edit route
  # we use the settings controller instead
  def edit
    redirect_to settings_path
  end
end
