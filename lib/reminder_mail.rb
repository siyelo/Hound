class ReminderMail
  include ActiveModel::Validations
  REMINDER_ATTRIBUTES = [:send_at, :delivered]
  MAIL_ATTRIBUTES = [:subject, :body, :cc]

  attr_accessor :reminder

  validate do
    [@reminder, @fetched_mail].each do |object|
      unless object.valid?
        object.errors.each do |key, values|
          errors[key] = values
        end
      end
    end
  end

  def initialize(reminder)
    @reminder = reminder
    @fetched_mail = @reminder.fetched_mail if @reminder
  end

  def cc
    @reminder.is_bcc? ? [] : @fetched_mail.all_addresses - HoundAddressList.new(@fetched_mail)
  end

  def to
    @fetched_mail.from
  end

  def all_recipients
    [to] + cc
  end

  def subject
    @fetched_mail.subject
  end

  def body
    @fetched_mail.body
  end

  def send_at
    @reminder.send_at
  end

  def delivered?
    @reminder.delivered?
  end

  def update_attributes(params = {})
    return false unless @reminder
    REMINDER_ATTRIBUTES.each do |attribute|
      @reminder.send("#{attribute}=", params[attribute]) if params[attribute]
    end
    MAIL_ATTRIBUTES.each do |attribute|
      @fetched_mail.send("#{attribute}=", params[attribute]) if params[attribute]
    end
    return false unless valid?
    save_objects
  end

  private

  def save_objects
    begin
      ActiveRecord::Base.transaction do
        @reminder.save!
        @fetched_mail.save!
      end
    rescue
      false
    end
  end
end

