class DateTime
  def self.parse_email(address)
    local_part = address.split('@')[0] 

    send_at = if local_part.match /(?!months)[a-z]{6,10}/
                EmailParser::AdverbParser.new(address).send_at
              elsif local_part.match /\d+[a-z]+/
                EmailParser::IncrementalTime.new(address).send_at
              end

    send_at || parse(local_part).change(hour: 8)
  end 
end
