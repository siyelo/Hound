class EmailAlias < ActiveRecord::Base
  ### Associations
  belongs_to :user

  ### Validations
  validates_presence_of :user, :email
  validates_with EmailValidator

  ### Attributes
  attr_accessible :email, :user

end
# == Schema Information
#
# Table name: email_aliases
#
#  id         :integer         not null, primary key
#  email      :string(255)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

