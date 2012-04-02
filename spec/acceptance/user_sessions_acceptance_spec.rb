require 'spec_helper_acceptance'

describe 'User', type: :request do
  before :each do
    @user = Factory(:user)
  end

  it 'receives an email and successfully reset password' do
    reset_mailer
    visit '/users/password/new'
    fill_in "user[email]", :with=>@user.email
    page.should have_content('Forgot your password?')
    click_button "Send me reset password instructions"

    unread_emails_for(@user.email).size.should >= parse_email_count(1)
    open_email(@user.email)
    email_should_have_body("Someone has requested a link to change your password, and you can do this through the link below.")
    click_first_link_in_email

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

  it 'is able to sign-up' do
    visit '/users/sign_up'
    within('body') do
      page.should have_content('Sign up')
    end

    fill_in "user[email]", :with => 'testing@test.com'
    fill_in "user[password]", :with=>"password"
    select "Sofia", :from => "Timezone"
    click_button 'Sign up'
    within('body') do
      page.should have_content('signed up successfully')
    end
  end

  it 'is able to sign-up if email used as someones alias' do
    alias_email = Factory :email_alias, user: @user, email: 't@test.com'
    visit '/users/sign_up'
    within('body') do
      page.should have_content('Sign up')
    end

    fill_in "user[email]", :with => alias_email.email
    fill_in "user[password]", :with=>"password"
    select "Sofia", :from => "Timezone"
    click_button 'Sign up'
    within('body') do
      page.should have_content('Email is already registered')
    end
  end

  def test_settings_page
    within('body') do
      page.should have_content 'Settings'
      page.should have_content 'General'
      page.should have_content 'Your other email addresses'
      page.should have_content 'Change Password'
      page.should have_content 'Close Account'
    end

    find(:css, "#user_confirmation_email").set(true)
    click_button 'Save'
    within('body') do
      page.should have_content 'You have successfully updated your settings.'
    end
  end

  it 'is able to edit their details excl. password (old devise redirect!)' do
    log_in_with(@user)
    visit '/users/edit'
    test_settings_page
  end

  it 'is able to edit their details excl. password via /settings' do
    log_in_with(@user)
    visit '/settings'
    test_settings_page
  end

  it 'is able to edit their details incl. password' do
    log_in_with(@user)

    visit '/users/edit'
    within('body') do
      page.should have_content('Settings')
    end
    fill_in "user[password]", with: 'password'
    fill_in "user[current_password]", with: 'testing'

    find(:css, "#user_confirmation_email").set(true)
    click_button 'Change my password'
    within('body') do
      page.should have_content('You have successfully updated your password.')
    end
  end

  it 'is able to change their timezone when accepting invite' do
    @user.invitation_token = '1234'
    @user.save
    visit '/activate?invitation_token=1234'
    page.should have_content('Timezone')
  end

end
