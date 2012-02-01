Mail.defaults do
  retriever_method :pop3, :address    => "pop.gmail.com",
                          :port       => 995,
                          :user_name  => 'hound@hound.cc',
                          :password   => 'houndyhound123',
                          :enable_ssl => true
end
