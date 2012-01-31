Factory.define :reminder do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
  f.body "Body of the email"
  f.reminder_time EmailParser::Parser.parse_email('0d@mailshotbot.com')
  f.delivered false
  f.user { Factory(:user)}
  f.cc []
 end

Factory.define :user do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.password "testing"
  f.password_confirmation "testing"
  f.timezone "Sofia"
end
