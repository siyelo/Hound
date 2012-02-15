Factory.define :reminder do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
  f.body "Body of the email"
  f.reminder_time 1.minute.from_now
  f.delivered false
  f.user { Factory(:user)}
  f.message_thread { Factory(:message_thread) }
  f.cc []
 end

Factory.define :user do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.password "testing"
  f.password_confirmation "testing"
  f.timezone "Sofia"
end

Factory.define :message_thread do |f|
  f.sequence(:message_id) { |n| n }
end

