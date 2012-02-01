require 'acceptance/acceptance_helper'

feature 'User sessions' do

  background do
    @user = Factory :user
    @reminder = Factory :reminder, user: @user
  end

  scenario 'user should receive an email and successfully reset password', js: true do
    #log_in_with(@user)
    visit '/users/sign_in'
    fill_in "user[email]", :with => @user.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'

    page.should have_content('You have 1 upcoming reminder')
    check 'reminder_delivered'
    page.should have_content('Saving')
    visit '/'
    page.should have_content('You have 0 upcoming reminder')

  end

end

