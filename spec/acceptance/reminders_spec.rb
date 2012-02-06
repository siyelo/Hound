require 'acceptance/acceptance_helper'

feature 'User sessions' do

  context 'manage reminders' do
    background do
      @user = Factory :user
      @reminder = Factory :reminder, user: @user
    end

    scenario 'user can mark a reminder as completed', js: true do
      log_in_with(@user)
      page.should have_content('You have 1 upcoming reminder')
      check 'reminder_delivered'
      page.should have_content('Saving')
      visit '/'
      page.should have_content('You have 0 upcoming reminder')
    end
  end

  context 'filter reminders' do
    background do
      @user = Factory :user
      reminder1 = Factory :reminder, user: @user, reminder_time: Time.now + 1.day
      reminder2 = Factory :reminder, user: @user, reminder_time: Time.now - 1.day, subject: 'failed reminder'
      reminder3 = Factory :reminder, user: @user, subject: 'reminder for today'
      reminder4 = Factory :reminder, user: @user, delivered: true, subject: 'delivered reminder'
      log_in_with(@user)
    end

    scenario 'user can filter reminders' do
      page.should have_content('You have 2 upcoming reminders')

      click_link 'Undelivered'
      page.should have_content('You have 1 undelivered reminder')
      page.should have_content('failed reminder')

      click_link 'Completed'
      page.should have_content('You have 1 completed reminder')
      page.should have_content('delivered reminder')

      click_link 'Due Today'
      page.should have_content('You have 1 reminder due today')
      page.should have_content('reminder for today')
    end

  end
end

