require 'spec_helper_acceptance'

describe 'User sessions', type: :request do
  before :each do
    @user = Factory(:user)
  end

  it 'receives an email and successfully reset password' do
    reset_mailer
    visit '/users/password/new'
    fill_in "user[email]", :with=>@user.email
    page.should have_content('Forgot your password?')
    click_button "Reset Password"

    unread_emails_for(@user.email).size.should >= parse_email_count(1)
    open_email(@user.email)
    email_should_have_body("Someone has requested a link to change your password, and you can do this through the link below.")
    visit_in_email("Change my password")

    within('body') do
      page.should have_content('Change your password')
    end

    fill_in "user[password]", :with=>"password"
    click_button "Change my password"

    within('body') do
      page.should have_content('Your password was changed successfully.')
    end
  end

  it 'is able to login' do
    log_in_with @user

    within('body') do
      page.should have_content('Signed in successfully')
    end
  end

  it 'is able to login with alias' do
    alias_email = Factory :email_alias, user: @user, email: 't@test.com'
    log_in_with @user

    within('body') do
      page.should have_content('Signed in successfully')
    end
  end

  it 'receives an email and successfully reset password' do
    reset_mailer
    visit '/users/password/new'
    page.should have_content('Forgot your password?')

    fill_in "user[email]", :with=>@user.email
    click_button "Reset Password"

    unread_emails_for(@user.email).size.should >= parse_email_count(1)
    open_email(@user.email)
    email_should_have_body("Someone has requested a link to change your password, and you can do this through the link below.")
    visit_in_email("Change my password")

    within('body') do
      page.should have_content('Change your password')
    end

    fill_in "user[password]", :with=>"password"
    click_button "Change my password"

    within('body') do
      page.should have_content('Your password was changed successfully.')
    end
  end
end
