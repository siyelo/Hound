require "minitest_helper"

class ReminderTest < MiniTest::Rails::Model
  before do
    @reminder = Reminder.new
  end

  it "must be valid" do
    @reminder.valid?.must_equal true
  end

  it "must be a real test" do
    flunk "Need real tests"
  end

  # describe "when doing its thing" do
  #   it "must be interesting" do
  #     @reminder.blow_minds!
  #     @reminder.interesting?.must_equal true
  #   end
  # end
end