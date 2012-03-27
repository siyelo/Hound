class RegistrationsController < Devise::RegistrationsController
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if (params[resource_name][:current_password]).blank?
      update_user_fields_except_password(resource)
    else
      update_user_fields_including_password(resource)
    end
  end

  private

  def update_user_fields_except_password(resource)
    params[resource_name].delete(:current_password)
    if resource.update_without_password(params[resource_name])
      set_flash_message :notice, :updated
      respond_with resource, :location => after_update_path_for(resource)
    else
      update_failed(resource)
    end
  end

  def update_user_fields_including_password(resource)
    if resource.update_with_password(params[resource_name])
      if is_navigational_format?
        set_flash_message :notice, :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      update_failed(resource)
    end
  end

  def update_failed(resource)
    clean_up_passwords resource
    respond_with resource
  end
end

