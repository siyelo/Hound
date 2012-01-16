module EmailHelper
  def self.extract_html_or_text(email)
    if email.html_part
      email.html_part.body.decoded
    else
      self.extract_text(email)
    end
  end

  private

  def self.extract_text(email)
    if email.multipart?
      email.text_part ? email.text_part.body.decoded : nil
    else
      email.body.decoded
    end
  end

end
