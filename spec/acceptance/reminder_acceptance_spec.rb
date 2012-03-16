require 'spec_helper_acceptance'

feature 'Reminders' do
  context 'complete reminders' do
    background do
      @user = Factory :user
      @reminder = Factory :reminder, user: @user,  send_at: DateTime.now + 1.month,
        fetched_mail: Factory(:fetched_mail, user: @user, subject: 'reminder1')
      log_in_with(@user)
    end

    scenario 'user can mark a reminder as completed', js: true do
      page.should have_content('You have 1 upcoming reminder')
      check 'reminder_delivered'
      page.should have_content('Saving')
      page.should have_content('saved')
      visit '/'
      page.should have_content('You have 0 upcoming reminder')
    end

    scenario 'user cannot change the status of an old reminder which has been delivered' do
      find('#reminder_delivered')['disabled'].should == nil #sanity - not disabled
      @reminder.send_at -= 1.month
      @reminder.delivered = true
      @reminder.save

      click_link 'Completed'
      page.should have_content('reminder1')
      find('#reminder_delivered')['disabled'].should == 'disabled'
    end

  end

  context 'edit reminders' do
    background do
      @user = Factory :user
      @reminder = Factory :reminder, user: @user,  send_at: DateTime.now + 1.month,
        fetched_mail: Factory(:fetched_mail, user: @user, subject: 'reminder1')
      log_in_with(@user)
      click_link 'reminder1'
    end

    scenario 'user can edit the reminder subject' do
      fill_in 'reminder_mail_subject', with: 'new subject'
      click_button 'submit'
      @reminder.reload
      @reminder.subject.should == 'new subject'
    end

    scenario 'user can edit the reminder time' do
      fill_in 'reminder_formatted_time', with: '20:30'
      click_button 'submit'
      @reminder.reload
      @reminder.send_at.min == '30'
      @reminder.send_at.hour == '20'
    end

    scenario 'user can edit the reminder body' do
      fill_in 'reminder_mail_body', with: 'new body'
      click_button 'submit'
      @reminder.reload
      @reminder.body.should == 'new body'
    end
  end

  context 'edit cc email addresses' do
    background do
      @user = Factory :user
      @reminder = Factory :reminder, user: @user,  send_at: DateTime.now + 1.month,
        fetched_mail: Factory(:fetched_mail, user: @user, subject: 'reminder1')
      log_in_with(@user)
    end

    scenario 'user can add multiple comma or semi-colon seperated email addresses', js: true do
      click_link 'reminder1'
      fill_in 'reminder_mail_cc', with: 'test@test1.com'
      click_button 'submit'
      click_link 'reminder1'
      find_field('reminder_mail_cc').value.should == 'test@test1.com'

      visit '/'
      click_link 'reminder1'
      fill_in 'reminder_mail_cc', with: 'test@test1.com; test@test2.com, test@test3.com'
      click_button 'submit'
      page.should_not have_content('Not all cc addresses are properly formed.')

      visit '/'
      click_link 'reminder1'
      fill_in 'reminder_mail_cc', with: 'test'
      click_button 'submit'
      page.should have_content('Not all cc addresses are properly formed.')

      visit '/'
      click_link 'reminder1'
      fill_in 'reminder_mail_cc', with: 'test@test1.com; test@sdva, test3.com'
      click_button 'submit'
      page.should have_content('Not all cc addresses are properly formed.')
    end
  end

  context 'filter reminders' do
    background do
      @user = Factory :user
      reminder1 = Factory :reminder, send_at: DateTime.now + 1.day,
        fetched_mail: Factory(:fetched_mail, user: @user, subject: 'reminder1')
      reminder2 = Factory :reminder, delivered: true, send_at: DateTime.now - 1.day,
        fetched_mail: Factory(:fetched_mail, user: @user, subject: 'delivered reminder')
      log_in_with(@user)
    end

    scenario 'user can filter reminders' do
      page.should have_content('You have 1 upcoming reminder')
      click_link 'Completed'
      page.should have_content('You have 1 completed reminder')
      page.should have_content('delivered reminder')
    end

  end
end
