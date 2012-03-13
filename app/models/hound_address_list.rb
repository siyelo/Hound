class HoundAddressList < Array

  def initialize(mail)
   super hound_addresses(mail)
  end

  private

  def all_addresses(mail)
    mail.to.to_a + mail.cc.to_a + mail.bcc.to_a
  end

  def hound_addresses(mail)
    all_addresses(mail).select { |a| a.include? '@hound.cc' }
  end
end
