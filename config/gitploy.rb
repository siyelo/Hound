require 'gitploy/script'

configure do |c|
  c.path = '/home/deployer/apps/radmeet'

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
    run "source /var/lib/jenkins/.bash_profile"
    run "source /var/lib/jenkins/.rvm/scripts/rvm"
    run "source #{config.path}/.rvmrc"
    run "rvm use 1.9.2@RadMeet"
    run "ruby -v"
    run "git reset --hard"
    run "bundle install"
    run "rake db:migrate"
    run "sudo service radmeet_unicorn restart"
    run "sudo restart radmeet"
    #run "touch tmp/restart.txt"
  end
end
