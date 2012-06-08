require 'gitploy/script'

configure do |c|
  c.path = '/home/hound/app'

  stage :production do
    c.host = 'butch.siyelo.com'
    c.user = 'hound'
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
    run "bundle install"
    run "rake db:migrate RAILS_ENV=production"
    run "bundle exec rake assets:precompile RAILS_ENV=production"
    run "sudo bundle exec foreman export upstart /etc/init/ -a hound -u hound"
    run "sudo sed -i \"1 i start on runlevel [2345]\" /etc/init/hound.conf"
    run "sudo /etc/init.d/hound_app restart"
    run "echo FINISHED."
  end
end
