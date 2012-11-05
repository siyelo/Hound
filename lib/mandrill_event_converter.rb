require 'json'
require 'mail'

class MandrillEventConverter
  attr_accessor :mandrill_event

  def initialize(mandrill_event_json)
    @mandrill_event = JSON.parse(mandrill_event_json)
  end

  def convert
    Mail.new(mandrill_event.first['msg']['raw_msg'])
  end
end
