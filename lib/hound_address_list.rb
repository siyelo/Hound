class HoundAddressList < Array
  DOMAIN = 'hound.cc'

  def initialize(fetched_mail)
    super hound_addresses(fetched_mail || FetchedMail.new)
  end

  def ignore_existing_hound_addresses_in_reply!(fetched_mail)
    if fetched_mail.parent
      parent_hounds = HoundAddressList.new(fetched_mail.parent)
      self - parent_hounds
    else
      self
    end
  end

  private

  def hound_addresses(fetched_mail)
    fetched_mail.all_addresses.select { |a| a.include? "@#{DOMAIN}" }
  end
end

class ParentHoundAddressList < HoundAddressList
  def initialize(fetched_mail)
    super fetched_mail.parent
  end
end
