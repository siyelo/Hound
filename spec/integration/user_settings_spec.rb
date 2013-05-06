require 'spec_helper_acceptance'

describe 'User Settings', type: :request do
  before :each do
    @user = FactoryGirl.create(:user)
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

end
