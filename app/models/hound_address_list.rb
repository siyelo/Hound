class HoundAddressList < Array
  def initialize(mail) 
    super hound_addresses(mail || Mail.new)
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

  def all_addresses(mail)
    mail.to.to_a + mail.cc.to_a + mail.bcc.to_a
  end

  def hound_addresses(mail)
    all_addresses(mail).select { |a| a.include? '@hound.cc' }
  end
end
