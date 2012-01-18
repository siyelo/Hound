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
    run "rvm use 1.9.2@RadMeet"
    run "git reset --hard"
    run "bundle install --deployment"
    run "sudo restart radmeet"
    run "sudo service radmeet_unicorn restart"
    #run "touch tmp/restart.txt"
  end
end
