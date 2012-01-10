module HelperMethods

  def log_in_with(user)
    visit "/login"
    fill_in "login_username", :with => user.username
    fill_in "login_password", :with => "secret"
    click_button "Login"
  end

  [:notice, :error].each do |name|
    define_method "should_have_#{name}" do |message|
      page.should have_css(".message.#{name}", :text => message)
    end
  end

  def should_be_on(path)
    page.current_url.should match(Regexp.new(path))
  end

  def should_not_be_on(path)
    page.current_url.should_not match(Regexp.new(path))
  end

  #email-spec helpers

  def email_should_have_body(text)
    current_email.default_part_body.to_s.should =~ Regexp.new(text)
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance

