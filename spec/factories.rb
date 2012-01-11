Factory.define :reminder do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
  f.reminder_time Time.now
end

Factory.define :user do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.password "testing"
  f.password_confirmation "testing"
end
