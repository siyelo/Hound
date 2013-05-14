# Hound.cc

# Getting Started

##
Ok so here's the deal
Lots of shizzle in here is run off resque, I found an awesome plugin called
resque scheduler (https://github.com/bvandenbos/resque-scheduler).
Read the documentation

I have it checking for new emails every minute.

To run this app, you actually need an instance of the scheduler running, so:

    rake resque:scheduler

then you need to start your workers:

    `rake resque:work QUEUE='*'`

and BAM. you're off to the racez.

## Setup

  - Define email username and password as ENV variables

    `ENV['HOUND_EMAIL_USERNAME']`
    `ENV['HOUND_EMAIL_PASSWORD']`

  - As hound user generate the upstart scripts

    $ bundle exec foreman export upstart hound_script -a hound -u hound
    $ sed -i "1 i start on runlevel [2345]" hound_script/hound.conf

  - Copy upstart scripts to /etc/init

    $ sudo cp /home/hound/app/hound_script/* /etc/init/

## Deployment

    * Install Ruby, Unicorn, Nginx and Postgres

    * Install Ruby, Unicorn, Nginx and Postgres

    * Add your public key to ~/.ssh/authorized_keys

    $ gitploy production setup

    $ gitploy production

    * SSH into the server

    `sudo ln -s /home/ubuntu/app/config/nginx.conf /etc/nginx/nginx.conf`

    `sudo ln -s /home/ubuntu/app/config/unicorn.sh /etc/init.d/unicorn`

    * Setup database.yml & run migrations

    * Restart Nginx, Unicorn and Hound services

## Development

  - For ruby-debug you need to install linecache manually

    curl -OL http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem

    gem install linecache19-0.5.13.gem
