Factory.define :reminder do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
  f.reminder_time Time.now
  f.delivered false
  f.user { Factory(:user)}
 end

Factory.define :user do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.password "testing"
  f.password_confirmation "testing"
end
