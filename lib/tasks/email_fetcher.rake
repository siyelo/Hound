desc "Starts email fetcher"
task :email_fetcher => :environment do
  FetchMailJob.instance.start
end
