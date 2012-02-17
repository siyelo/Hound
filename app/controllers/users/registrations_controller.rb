class Users::RegistrationsController < Devise::RegistrationsController
  def edit
    @alias = EmailAlias.new
  end
end
