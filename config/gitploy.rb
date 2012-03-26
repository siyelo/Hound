require 'gitploy/script'

configure do |c|
  c.path = '/home/deployer/apps/hound'

  stage :staging do
    c.host = 'mrpink.siyelo.com'
    c.user = 'deployer'
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
    run "source /home/deployer/.bash_profile"
    run "source /home/deployer/.rvm/scripts/rvm"
    run "source #{config.path}/.rvmrc"
    run "rvm use 1.9.2@hound"
    run "ruby -v"
    run "rvm wrapper ruby-1.9.2-p290@hound bootup unicorn_rails"
    run "git reset --hard"
    run "cp config/database.yml.pg config/database.yml"
    run "bundle install"
    run "rake db:migrate"
    run "rake assets:precompile"
    run "rvmsudo foreman export upstart /etc/init -a hound -u deployer"
    run "sudo service hound_unicorn restart"
    run "sudo restart hound"
    #run "touch tmp/restart.txt"
  end
end
