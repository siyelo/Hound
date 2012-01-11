class Reminder < ActiveRecord::Base
  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject

end
