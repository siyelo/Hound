require 'rubygems'
gem 'ruby-debug-base19x'
gem 'mail'
require 'ruby-debug'
require 'mail'
require_relative './email_body_parser'

require 'net/imap'
SERVER   = 'imap.gmail.com'
USERNAME = 'hound@hound.cc'
PASSWORD = 'houndyhound123'
FOLDER   = 'INBOX'

# imap connection
@imap = Net::IMAP.new SERVER, :ssl => true
@imap.login USERNAME, PASSWORD
# @imap.examine
@imap.select(FOLDER)

def print_mail(mail)
  puts mail.subject
  puts EmailBodyParser.extract_html_or_text_from_body(mail)
  puts mail.from.first.to_s if mail.from
  puts mail.to
  puts mail.cc
  puts mail.bcc
  puts mail.message_id
  puts mail.in_reply_to
end

def fetch_messages
  @imap.search(["ALL"]).each do |message_id|
    puts message_id
    fetchdata = @imap.fetch(message_id, ['RFC822'])[0]
    mail = Mail.new(fetchdata.attr['RFC822'])
    print_mail(mail)

    puts "deleting #{message_id}"
    @imap.store(message_id, "+FLAGS", [:Deleted])
  end
end

puts 'Starting engines...'
loop do
  puts 'waiting...'
  @imap.idle do |resp|
    # modify this to do something more interesting.
    # called every time a response arrives from the server.
    if resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == "EXISTS"
      puts "Mailbox now has #{resp.data} messages"
      @imap.idle_done
    end
  end

  fetch_messages
end
