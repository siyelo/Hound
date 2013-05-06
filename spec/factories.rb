FactoryGirl.define do
  factory :reminder do
    association :fetched_mail, factory: :fetched_mail
    time         { '1min' }
    send_at      { 1.minute.from_now.to_time }
    delivered    { false }
    other_recipients { ["another@sorad.com"] }
  end

  factory :user do
    sequence(:email)      { |n| "somedude#{n}@sorad.com" }
    password              { "testing" }
    password_confirmation { "testing" }
    timezone              { "Sofia" }
  end

  factory :email_alias do
    association :user, factory: :user
    sequence(:email) { |n| "smartypants#{n}@blah.com" }
  end

  factory :fetched_mail do
    association :user, factory: :user
    to        { ["1d@hound.cc"] }
    from      { "somedude@sorad.com" }
    subject   { "Reminder subject" }
    body      { "<h1> HTML body </h1>" }
    cc        { ["another@sorad.com"] }
    bcc       { [] }
    sequence(:message_id)
  end
end


