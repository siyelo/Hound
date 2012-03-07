module EmailParser

  def self.parse(address)
    #http://en.wikipedia.org/wiki/Email_address#Local_part
    local_part = address.split('@')[0]

    send_at = if local_part.match /(?!months)[a-z]{6,10}/
                EmailParser::AdverbParser.new(address).send_at
              elsif local_part.match /\d+[a-z]+/
                EmailParser::IncrementalTime.new(address).send_at
              end

    send_at || DateTime.parse(local_part).change(hour: 8)
  end
end
