module ScriptHelper
  DEFAULT_PRODUCTION_APP = 'hound'

  def run(cmd)
    puts "=> "+ cmd + "\n"
    output = `#{cmd}`
    result = $?.success?
    puts output
    result
  end

  def run_or_die(cmd)
    result = run(cmd)
    fail_and_exit unless result == true
    result
  end

  def fail_and_exit
    puts "...failed. Exiting...."
    exit(false)
  end

  def get_date
    `date '+%Y-%m-%d-%H%Mhrs'`.chomp
  end
end

