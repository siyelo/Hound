module HelperMethods

  def log_in_with(user)
    visit '/users/sign_in'
    fill_in "user[email]", :with => @user.email
    fill_in "user[password]", :with=> 'testing'
    click_button 'Sign in'
  end

  [:notice, :error].each do |name|
    define_method "should_have_#{name}" do |message|
      page.should have_css(".message.#{name}", :text => message)
    end
  end

  def handle_js_confirm(accept=true)
    page.evaluate_script "window.original_confirm_function = window.confirm"
    page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
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

