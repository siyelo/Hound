class ReminderConfirmationObserver < ActiveRecord::Observer
   observe :reminder
  
   def after_create(reminder)
     if reminder.user.confirmation_email?
       Resque.enqueue(SendConfirmationWorker, reminder.id) 
     end
   end
end
