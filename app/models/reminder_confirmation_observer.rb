class ReminderConfirmationObserver < ActiveRecord::Observer
   observe :reminder
  
   def after_create(reminder)
     Resque.enqueue(SendConfirmationWorker, reminder.id) if reminder.user.confirmation_email?
    end
end
