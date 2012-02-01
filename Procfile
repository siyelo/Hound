fetchworker: bundle exec rake resque:work QUEUE=fetch_queue
queueworker: bundle exec rake resque:work QUEUE=process_queue
sendconfworker: bundle exec rake resque:work QUEUE=confirm_queue
sendremworker: bundle exec rake resque:work QUEUE=send_queue
snoozenotworker: bundle exec rake resque:work QUEUE=snooze_queue
randomworker: bundle exec rake resque:work QUEUE='*'

scheduler: bundle exec rake resque:scheduler


