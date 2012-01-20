God::Watch.class_eval do
  # Default Integer interval at which keepalive will runn poll checks.
  DEFAULT_KEEPALIVE_INTERVAL = 5.seconds

  # Default Integer or Array of Integers specification of how many times the
  # memory condition must fail before triggering.
  DEFAULT_KEEPALIVE_MEMORY_TIMES = [3, 5]

  # Default Integer or Array of Integers specification of how many times the
  # CPU condition must fail before triggering.
  DEFAULT_KEEPALIVE_CPU_TIMES = [3, 5]

  def keepalive(options = {})
    if God::EventHandler.loaded?
      self.transition(:init, { true => :up, false => :start }) do |on|
        on.condition(:process_running) do |c|
          c.interval = options[:interval] || DEFAULT_KEEPALIVE_INTERVAL
          c.running = true
        end
      end

      self.transition([:start, :restart], :up) do |on|
        on.condition(:process_running) do |c|
          c.interval = options[:interval] || DEFAULT_KEEPALIVE_INTERVAL
          c.running = true
        end
      end

      self.transition(:up, :start) do |on|
        on.condition(:process_exits)
      end
    else
      self.start_if do |start|
        start.condition(:process_running) do |c|
          c.interval = options[:interval] || DEFAULT_KEEPALIVE_INTERVAL
          c.running = false
        end
      end
    end

    self.restart_if do |restart|
      if options[:memory_max]
        restart.condition(:memory_usage) do |c|
          c.interval = options[:interval] || DEFAULT_KEEPALIVE_INTERVAL
          c.above = options[:memory_max]
          c.times = options[:memory_times] || DEFAULT_KEEPALIVE_MEMORY_TIMES
        end
      end

      if options[:cpu_max]
        restart.condition(:cpu_usage) do |c|
          c.interval = options[:interval] || DEFAULT_KEEPALIVE_INTERVAL
          c.above = options[:cpu_max]
          c.times = options[:cpu_times] || DEFAULT_KEEPALIVE_CPU_TIMES
        end
      end
    end
  end
end

God.watch do |w|
  w.name = 'Beanstalk'
  w.start = 'beanstalkd'
  w.keepalive
end

God.watch do |w|
  w.name = 'MySQL'
  w.start = 'mysqld --basedir=$HOME/opt/mysql --datadir=$HOME/mysql/run_state/data/'
  w.stop = 'mysqladmin -u root shutdown'
  w.restart = 'mysqladmin -u root restart'
  w.keepalive
end

RAILS_ROOT = File.expand_path('../../', __FILE__)
num_cores = (ENV['WORKERS'] || 22).to_i
num_cores.times do |n|
  God.watch do |w|
    w.name = "Stalk Agent Ticks ##{n}"
    w.start = "BEANSTALK_URL='beanstalk://opt-a007:11300' stalk #{RAILS_ROOT}/lib/jobs/agent_tick_job.rb"
    w.keepalive
  end
end
