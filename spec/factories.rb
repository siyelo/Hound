Factory.define :reminder do |f|
  f.sequence(:email) { |n| "somedude#{n}@sorad.com" }
  f.subject "pewpepw"
end
