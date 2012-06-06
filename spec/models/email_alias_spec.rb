require 'spec_helper'

describe EmailAlias do
  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :email }

    context 'should validate uniqueness of email across Aliases and Users' do
      before :each do
        @user = Factory :user, email: 'batman@gotham.com'
      end

      it 'should validate uniquess of email within Aliases' do
        alias_email = Factory :email_alias, email: 'clark@kent.com', user: @user
        alias_email2 = Factory.build :email_alias,  email: 'clark@kent.com', user: @user
        alias_email2.valid?.should be_false
        alias_email2.errors[:email].should include 'is already registered'
      end

      it 'should validate uniqueness of email within Users' do
        alias_email = Factory.build :email_alias,  email: 'batman@gotham.com', user: @user
        alias_email.valid?.should be_false
        alias_email.errors[:email].should include 'is already registered'
      end
    end
  end
end
