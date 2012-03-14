Factory.define :reminder do |f|
  f.fetched_mail { Factory :fetched_mail }
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
  f.body "Body of the email"
  f.send_at 1.minute.from_now
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

Factory.define :email_alias do |f|
  f.user { Factory(:user) }
  f.sequence(:email) { |n| "smartypants#{n}@blah.com" }
end

Factory.define :fetched_mail do |f|
  f.user { Factory :user }
  f.to ["1d@hound.cc"]
  f.from "somedude@sorad.com"
  f.subject "Reminder subject"
  f.body "<h1> HTML body </h1>"
  f.cc ["another@sorad.com"]
  f.bcc []
  f.sequence(:message_id)
end

