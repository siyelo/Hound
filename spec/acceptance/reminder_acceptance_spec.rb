require 'spec_helper_acceptance'

describe 'User', type: :request do
  let(:user) { Factory :user }

  context 'edit reminders' do
    before :each do
      @reminder = Factory :reminder, user: user,  send_at: DateTime.now + 1.month,
        fetched_mail: Factory(:fetched_mail, user: user, subject: 'reminder1')
      log_in_with(user)
      click_link 'reminder1'
    end

    it 'can edit the reminder subject' do
      fill_in 'Subject:', with: 'new subject'
      click_button 'submit'
      page.should have_content('new subject')
      @reminder.reload
      @reminder.subject.should == 'new subject'
    end

    it 'can remove the reminder subject' do
      fill_in 'Subject:', with: ""
      click_button 'submit'
      page.should have_content('<No Subject>')
      @reminder.reload
      @reminder.subject.should == ''
    end

    it 'can edit the reminder time' do
      fill_in 'Reminder time:', with: '3days'
      click_button 'submit'
      click_link 'reminder1'
      find_field('Reminder time:').value.should == '3days'
    end
  end

  context 'edit cc email addresses' do
    before :each do
      @reminder = Factory :reminder, user: user,  send_at: DateTime.now + 1.month,
        fetched_mail: Factory(:fetched_mail, user: user, subject: 'reminder1')
      log_in_with(user)
    end

    it 'can add multiple comma or semi-colon seperated email addresses', js: true do
      click_link 'reminder1'
      fill_in 'Cc:', with: 'test@test1.com'
      click_button 'submit'
      click_link 'reminder1'
      find_field('Cc:').value.should == 'test@test1.com'

      visit '/'
      click_link 'reminder1'
      fill_in 'Cc:', with: 'test@test1.com; test@test2.com, test@test3.com'
      click_button 'submit'
      page.should_not have_content('Not all Cc addresses are well formatted')

      visit '/'
      click_link 'reminder1'
      fill_in 'Cc:', with: 'test'
      click_button 'submit'
      page.should have_content('Not all Cc addresses are well formatted')

      visit '/'
      click_link 'reminder1'
      fill_in 'Cc:', with: 'test@test1.com; test@sdva, test3.com'
      click_button 'submit'
      page.should have_content('Not all Cc addresses are well formatted')
    end
  end

  context 'filter reminders' do
    it 'can filter reminders' do
      Factory :reminder, send_at: DateTime.now + 1.day,
        fetched_mail: Factory(:fetched_mail, user: user, subject: 'reminder1')
      Factory :reminder, delivered: true, send_at: DateTime.now - 1.day,
        fetched_mail: Factory(:fetched_mail, user: user, subject: 'delivered reminder')
      log_in_with(user)

      page.should have_content('You have 1 upcoming reminder')
      click_link 'Completed'
      page.should have_content('You have 1 completed reminder')
      page.should have_content('delivered reminder')
    end

    it 'does not display cleaned reminders' do
      Factory :reminder, delivered: true, cleaned: true, send_at: DateTime.now - 1.day,
        fetched_mail: Factory(:fetched_mail, user: user, subject: 'delivered reminder')
      log_in_with(user)

      page.should have_content('You have 0 upcoming reminder')
      click_link 'Completed'
      page.should have_content('You have 0 completed reminder')
    end
  end
end
