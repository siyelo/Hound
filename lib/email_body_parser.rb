module EmailBodyParser
  def self.extract_html_or_text_from_body(message)
    if message.html_part
      message.html_part.body.decoded
    else
      extract_text_from_body(message)
    end
  end

  private

  def self.extract_text_from_body(message)
    if message.multipart?
      message.text_part ? message.text_part.body.decoded : nil
    else
      message.body.decoded
    end
  end
end
