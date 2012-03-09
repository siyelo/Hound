class FetchedMail

  attr_accessor :to, :from, :subject, :body, :cc, :bcc, :in_reply_to

  def initialize(mail = Mail.new)
    @to = mail.to
    @from = mail.from.first.to_s if mail.from
    @subject = mail.subject
    @body = extract_html_or_text(mail)
    @cc = mail.cc || []
    @bcc = mail.bcc || []
    @in_reply_to = mail.in_reply_to
  end

  def to_hound
    all_addresses.select{ |t| t.include?('@hound.cc') }
  end

  def not_to_hound
    all_addresses.select{ |t| !t.include?('@hound.cc') }
  end

  private

    def extract_html_or_text(message)
      if message.html_part
        message.html_part.body.decoded
      else
        extract_text(message)
      end
    end

    def extract_text(message)
      if message.multipart?
        message.text_part ? message.text_part.body.decoded : nil
      else
        message.body.decoded
      end
    end

    def all_addresses
      to + cc + bcc + [from]
    end
end
