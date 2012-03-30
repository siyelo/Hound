fetchworker: bundle exec rake email_fetcher
queueworker: bundle exec rake resque:work QUEUE=process_queue
sendconfworker: bundle exec rake resque:work QUEUE=confirm_queue
sendremworker: bundle exec rake resque:work QUEUE=send_queue
notificationworker: bundle exec rake resque:work QUEUE=notification_queue
randomworker: bundle exec rake resque:work QUEUE='*'

scheduler: bundle exec rake resque:scheduler


