require 'queuer'

module Resque; end
class SendReminderWorker; end

describe Queuer do
  it "should enqueue multiple reminders" do
    r1 = mock :reminder, id: 1
    r2 = mock :reminder, id: 2
    Resque.stub(:enqueue).and_return true
    Resque.should_receive(:enqueue).twice
    Queuer.add_all_to_send_queue([r1,r2])
  end

  it "should accept nil multiple reminders" do
    lambda do
      Queuer.add_all_to_send_queue(nil)
    end.should_not raise_exception
  end
end
