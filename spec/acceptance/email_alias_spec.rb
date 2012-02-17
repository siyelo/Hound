require 'acceptance/acceptance_helper'

feature 'Email Aliases' do

  background do
    @user = Factory(:user)
    log_in_with(@user)
  end

  scenario 'user should be able to add email addresses', js: true do
    visit '/users/edit'
    page.should have_content('Your other email addresses')
    fill_in 'email_alias_email', with: 'test'
    click_button 'add_alias'
    page.should have_content('test [delete]')
    fill_in 'email_alias_email', with: 'test'
    click_button 'add_alias'
    page.should have_content('Email already in use')
  end

  scenario 'user should be able to delete alias addresses', js: true do
    Factory(:email_alias, email: 'test', user: @user)
    visit '/users/edit'
    page.should have_content('test [delete]')
    click_link '[delete]'
    handle_js_confirm
    page.should_not have_content('test [delete]')
  end
end
