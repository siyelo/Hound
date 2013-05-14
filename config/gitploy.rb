require 'gitploy/script'

configure do |c|
  c.path = '/home/ubuntu/app'

  stage :production do
    c.host = 'ec2-54-245-208-6.us-west-2.compute.amazonaws.com'
    c.user = 'ubuntu'
  end
end

setup do
  remote do
    run "mkdir -p #{config.path}"
    run "cd #{config.path} && git init"
    run "git config --bool receive.denyNonFastForwards false"
    run "git config receive.denyCurrentBranch ignore"
  end
end

deploy do
  push!
  remote do
    run "cd #{config.path}"
    run "git reset --hard"
    run 'export PATH="$HOME/.rbenv/bin:$PATH"'
    run 'eval "$(rbenv init -)"'
    run "ruby -v"
    run "gem install bundler"
    run "rbenv rehash"
    run "bundle install --deployment --without development, testing"
    run "rbenv rehash"
    run "rbenv sudo bundle exec foreman export upstart hound_scripts -a hound -u ubuntu"
    run "sudo cp hound_scripts/* /etc/init/"
    run "sudo rm -rf hound_scripts"
    run "sudo sed -i \"1 i start on runlevel [2345]\" /etc/init/hound.conf"
    # EC2 micro instance might not have enought RAM to run asset precompilation
    # without stopping hound service first
    run "sudo service hound restart"
    run "rbenv sudo RAILS_ENV=production rake db:migrate"
    run "rbenv sudo RAILS_ENV=production bundle exec rake assets:precompile"
    run "echo FINISHED."
  end
end
