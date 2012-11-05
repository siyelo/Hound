class InboundEmailController < ApplicationController
  def create
    mail = MandrillEventConverter.new(params['mandrill_events']).convert
    ReminderCreationService.new.create!(mail)

    render nothing: true
  end

  def index
    render nothing: true
  end
end

