module Services
  class EmailReminder

    ATTRIBUTES = [:to, :from, :cc, :subject, :body, :message_id]

    attr_accessor *ATTRIBUTES

    def initialize(email)
      ATTRIBUTES.each do |attribute|
        send("#{attribute}=", email_params[attribute])
      end
    end
  end
end
