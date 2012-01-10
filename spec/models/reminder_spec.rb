require 'spec_helper'

describe Reminder do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :subject }
  end

  describe "parse addresses" do
    before :each do
      Timecop.freeze
    end

    it "should detect the minutes" do
      email = "2minutes@radmeet.cc"
      Reminder.parse_email(email).should == 2.minutes.from_now
    end

    it "should detect the hours" do
      email = "2hours@radmeet.cc"
      Reminder.parse_email(email).should == 2.hours.from_now
    end

    it "should detect the days" do
      email = "2days@radmeet.cc"
      Reminder.parse_email(email).should == 2.days.from_now
    end

    it "should detect the months" do
      email = "2months@radmeet.cc"
      Reminder.parse_email(email).should == 2.months.from_now
    end

    it "should detect the years" do
      email = "2years@radmeet.cc"
      Reminder.parse_email(email).should == 2.years.from_now
    end

    it "should detect everything" do
      email = "2years3months12days23hours1minute@radmeet.cc"
      Reminder.parse_email(email).should == (2.years + 3.months + 12.days +
                                             23.hours + 1.minute).from_now
    end

  end

end
