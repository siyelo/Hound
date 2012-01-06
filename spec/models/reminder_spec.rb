require 'spec_helper'

describe Reminder do
  it { should validate_presence_of :email }
  it { should validate_presence_of :subject }

end
