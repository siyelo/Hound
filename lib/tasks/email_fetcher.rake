desc "Starts email fetcher"
task :email_fetcher => :environment do
  fetch_mail_job = FetchMailJob.new
  fetch_mail_job.start
end
