module EmailParser
  require 'active_support/core_ext/date_time/calculations'

  require 'email_parser/adverb_parser'
  require 'email_parser/incremental_time'

  def self.parse(address)
    #http://en.wikipedia.org/wiki/Email_address#Local_part
    local_part = address.split('@')[0]

    send_at = if local_part.match /(?!months)[a-z]{6,10}/
                EmailParser::AdverbParser.parse(address)
              elsif local_part.match /\d+[a-z]+/
                EmailParser::IncrementalTime.parse(address)
              end

    send_at || DateTime.parse(local_part).change(hour: 8)
  end
end
