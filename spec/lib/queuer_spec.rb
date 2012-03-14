require 'spec_helper'

describe Queuer do
  it "should enqueue multiple reminders" do
    r1 = Reminder.new
    r1.stub(:id).and_return(1)
    r2 = Reminder.new
    r2.stub(:id).and_return(2)
    Resque.should_receive(:enqueue).twice
    Queuer.add_all_to_send_queue([r1,r2])
  end

  it "should accept nil multiple reminders" do
    lambda do
      Queuer.add_all_to_send_queue(nil)
    end.should_not raise_exception
  end

  it "should enqueue a single reminder" do
    r1 = Reminder.new
    r1.stub(:id).and_return(1)
    Resque.should_receive(:enqueue).once
    Queuer.add_to_send_queue(r1)
  end

end
