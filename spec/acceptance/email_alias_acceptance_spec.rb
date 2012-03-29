require 'spec_helper_acceptance'

describe 'User', type: :request do
  before :each do
    @user = Factory(:user)
    log_in_with(@user)
  end

  it 'is able to add email addresses', js: true do
    visit '/users/edit'
    page.should have_content('Your other email addresses')
    fill_in 'email_alias_email', with: 'test'
    click_button 'add_alias'
    page.should have_content('test [delete]')
    fill_in 'email_alias_email', with: 'test'
    click_button 'add_alias'
    page.should have_content('Email already in use')
  end

  it 'is able to delete alias addresses', js: true do
    Factory(:email_alias, email: 'test', user: @user)
    visit '/users/edit'
    page.should have_content('test [delete]')
    click_link '[delete]'
    handle_js_confirm
    page.should_not have_content('test [delete]')
  end
end
