Factory.define :reminder do |f|
  f.fetched_mail { Factory :fetched_mail }
  f.time         { '1min' }
  f.send_at      { 1.minute.from_now.to_time }
  f.delivered    { false }
  f.other_recipients { ["another@sorad.com"] }
 end

Factory.define :user do |f|
  f.sequence(:email)      { |n| "somedude#{n}@sorad.com" }
  f.password              { "testing" }
  f.password_confirmation { "testing" }
  f.timezone              { "Sofia" }
end

Factory.define :email_alias do |f|
  f.user             { Factory(:user) }
  f.sequence(:email) { |n| "smartypants#{n}@blah.com" }
end

Factory.define :fetched_mail do |f|
  f.user      { Factory :user }
  f.to        { ["1d@hound.cc"] }
  f.from      { "somedude@sorad.com" }
  f.subject   { "Reminder subject" }
  f.body      { "<h1> HTML body </h1>" }
  f.cc        { ["another@sorad.com"] }
  f.bcc       { [] }
  f.sequence(:message_id)
end

