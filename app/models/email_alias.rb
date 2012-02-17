class EmailAlias < ActiveRecord::Base
  ### Associations
  belongs_to :user

  ### Validations
  validates_presence_of :user, :email
  validates_with EmailValidator

  ### Attributes
  attr_accessible :email, :user

end
