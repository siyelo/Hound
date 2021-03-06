require 'spec_helper_acceptance'

describe 'User', type: :request do
  let(:user) { FactoryGirl.create :user }

  context 'edit reminders' do
    before :each do
      @reminder = FactoryGirl.create :reminder, user: user,  send_at: DateTime.now + 1.month,
        fetched_mail: FactoryGirl.create(:fetched_mail, user: user, subject: 'reminder1')
      log_in_with(user)
      click_link 'reminder1'
    end

    it 'can edit the reminder time' do
      fill_in 'reminder_time', with: '3days'
      click_button 'submit'
      click_link 'reminder1'
      find_field('reminder_time').value.should == '3days'
    end
  end

  context 'filter reminders' do
    it 'can filter reminders' do
      FactoryGirl.create :reminder, send_at: DateTime.now + 1.day,
        fetched_mail: FactoryGirl.create(:fetched_mail, user: user, subject: 'reminder1')
      FactoryGirl.create :reminder, delivered: true, send_at: DateTime.now - 1.day,
        fetched_mail: FactoryGirl.create(:fetched_mail, user: user, subject: 'delivered reminder')
      log_in_with(user)

      page.should have_content('You have 1 upcoming reminder')
      click_link 'Completed'
      page.should have_content('You have 1 completed reminder')
      page.should have_content('delivered reminder')
    end

    it 'does not display cleaned reminders' do
      FactoryGirl.create :reminder, delivered: true, cleaned: true, send_at: DateTime.now - 1.day,
        fetched_mail: FactoryGirl.create(:fetched_mail, user: user, subject: 'delivered reminder')
      log_in_with(user)

      page.should have_content('You have 0 upcoming reminder')
      click_link 'Completed'
      page.should have_content('You have 0 completed reminder')
    end
  end
end
