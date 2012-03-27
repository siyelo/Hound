require 'spec_helper_acceptance'

feature 'User sessions' do

  background do
    @user = Factory(:user)
  end

  scenario 'user should receive an email and successfully reset password' do
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

  scenario 'user should be able to login' do
    visit '/users/sign_in'
    fill_in "user[email]", :with => @user.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'

    within('body') do
      page.should have_content('Signed in successfully')
    end
  end

  scenario 'user should be able to login with alias' do
    alias_email = Factory :email_alias, user: @user, email: 't@test.com'
    visit '/users/sign_in'
    fill_in "user[email]", :with => alias_email.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'

    within('body') do
      page.should have_content('Signed in successfully')
    end

  end

  scenario 'user should be able to sign-up' do
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

  scenario 'user should not be able to sign-up if email used as someones alias' do
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

  scenario 'user should be able to edit their details excl. password' do
    visit '/users/sign_in'
    fill_in "user[email]", :with => @user.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'

    visit '/users/edit'
    within('body') do
      page.should have_content('Edit your profile')
    end

    find(:css, "#user_confirmation_email").set(true)
    click_button 'Update'
    within('body') do
      page.should have_content('You updated your account successfully.')
    end
  end

  scenario 'user should be able to edit their details incl. password' do
    visit '/users/sign_in'
    fill_in "user[email]", :with => @user.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'

    visit '/users/edit'
    within('body') do
      page.should have_content('Edit your profile')
    end
    fill_in "user[password]", with: 'password'
    fill_in "user[current_password]", with: 'testing'

    find(:css, "#user_confirmation_email").set(true)
    click_button 'Update'
    within('body') do
      page.should have_content('You updated your account successfully.')
    end
  end
end
