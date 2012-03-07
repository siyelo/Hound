class HoundAddressList < Array
  def initialize(mail)
    super hound_addresses(mail || FetchedMail.new)
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

  def hound_addresses(mail)
    mail.all_addresses.select { |a| a.include? '@hound.cc' }
  end
end
