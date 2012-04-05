require 'spec_helper_acceptance'

describe 'user registrations', type: :request do
  it 'is able to sign-up' do
    visit '/users/sign_up'
    within('body') do
      page.should have_content('Sign up')
    end

    fill_in "user[email]", :with => 'testing@test.com'
    fill_in "user[password]", :with=>"password"
    select "Sofia", :from => "Your Timezone"
    click_button 'Sign up'
    within('body') do
      page.should have_content('signed up successfully')
    end

    within('body') do
      page.should have_content 'Your Reminders'
      page.should have_content 'Schedule a new reminder now!'
    end
  end

  it 'is not able to sign up with already registered email' do
    user = Factory :user, email: 'g@g.com'
    visit '/users/sign_up'
    within('body') do
      page.should have_content('Sign up')
    end

    fill_in "user[email]", :with => 'g@g.com'
    fill_in "user[password]", :with=>"password"
    select "Sofia", :from => "Timezone"
    click_button 'Sign up'
    within('body') do
      page.should have_content 'Email has already been taken'
    end
  end

  it 'is able to sign-up if email used as someones alias' do
    user = Factory :user
    alias_email = Factory :email_alias, user: user, email: 't@test.com'
    visit '/users/sign_up'
    within('body') do
      page.should have_content('Sign up')
    end

    fill_in "user[email]", :with => alias_email.email
    fill_in "user[password]", :with=>"password"
    select "Sofia", :from => "Your Timezone"
    click_button 'Sign up'
    within('body') do
      page.should have_content('Email is already registered')
    end
  end

  it 'is able to change their timezone when accepting invite' do
    user = Factory :user, invitation_token: '1234'
    visit '/activate?invitation_token=1234'
    page.should have_content('Timezone')
  end
end
