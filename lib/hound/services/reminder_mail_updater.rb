require 'active_support/core_ext/time/zones'
require 'active_support/values/time_zone'
require 'active_support/core_ext/date_time/calculations'

module Hound
  class ReminderMailUpdater
    REMINDER_ATTRIBUTES = [:send_at, :delivered, :other_recipients]
    MAIL_ATTRIBUTES = [:subject, :body]

    attr_reader :reminder

    def perform(user, params)
      @reminder = user.reminders.find_by_id params[:id]
      return false unless @reminder
      @fetched_mail = @reminder.fetched_mail
      parse_send_at! params
      update_fields params[:reminder]
      save_entities
    end

    def errors
      @reminder.valid?
      unless @fetched_mail.valid?
        @fetched_mail.errors.each do |key, values|
         @reminder.errors[key] = values
        end
      end

      @reminder.errors
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
        errors
        false
      end
    end

    def parse_send_at!(params)
      if params[:reminder].present? && !params[:reminder][:send_at].present?
        if params[:formatted_date].present? || params[:formatted_time].present?
          date_string = params.delete(:formatted_date) + ' ' +
            params.delete(:formatted_time)
          date = DateTime.parse(date_string)
          params[:reminder][:send_at] = date.
            change(offset: Time.zone.formatted_offset)
        end
      end
    end
  end
end
