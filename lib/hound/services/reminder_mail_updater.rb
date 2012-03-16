require 'active_support/core_ext/time/zones'
require 'active_support/values/time_zone'
require 'active_support/core_ext/date_time/calculations'

require 'reminder_mail'

module Hound
  class ReminderMailUpdater
    REMINDER_ATTRIBUTES = [:send_at, :delivered]
    MAIL_ATTRIBUTES = [:subject, :body, :cc]

    attr_reader :reminder

    def perform(user, params)
      @reminder = user.reminders.find_by_id params[:id]
      return false unless @reminder
      @fetched_mail = @reminder.fetched_mail
      parse_send_at! params
      update_fields params[:reminder_mail]
      save_entities
    end

    def errors
      _errors = {}
      [@reminder, @fetched_mail].each do |object|
        unless object.valid?
          object.errors.each do |key, values|
            _errors[key] = values
          end
        end
      end
      _errors
    end

    def reminder_mail
      ReminderMail.new(@reminder, errors)
    end

    private

    def update_fields(params = {})
      update_allowed_attributes(MAIL_ATTRIBUTES, @fetched_mail, params)
      update_allowed_attributes(REMINDER_ATTRIBUTES, @reminder, params)
    end

    def update_allowed_attributes(attributes, object, params = {})
      attributes.each do |attribute|
        object.send("#{attribute}=", params[attribute]) if params[attribute]
      end
    end

    def save_entities
      begin
        ActiveRecord::Base.transaction do
          @reminder.save!
          @fetched_mail.save!
        end
      rescue Exception => e
        false
      end
    end

    def parse_send_at!(params)
      if params[:reminder_mail] && !params[:reminder_mail][:send_at]
        if params[:formatted_date] || params[:formatted_time]
          date = DateTime.parse params.delete(:formatted_date) +' '+ params.delete(:formatted_time)
          params[:reminder_mail][:send_at] = date.change(offset: Time.zone.formatted_offset)
        end
      end
    end
  end
end
