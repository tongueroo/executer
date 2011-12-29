class Executer
  class Client

    attr_reader :redis_1, :redis_2

    def initialize(config)
      if File.exist?(config)
        options = YAML.load(File.read(config))
        redis_url = options['redis']
        @logger = Logger.new(options['log'] || '/var/log/executer.log')
      else
        redis_url = config
        @logger = Logger.new('/var/log/executer.log')
      end
      @redis_1 = Redis.connect(:url => "redis://#{redis_url}")
      @redis_2 = Redis.connect(:url => "redis://#{redis_url}")
    end

    def run(options)
      id = options[:id]
      options = Yajl::Encoder.encode(options)

      Timeout.timeout(60*60) do
        @redis_1.subscribe("executer:response:#{id}") do |on|
          on.subscribe do |channel, subscriptions|
            log("Queuing: #{options.inspect}")
            @redis_2.rpush "executer:request", options
          end

          on.message do |channel, message|
            log("Finished: #{message.inspect}")
            if message == 'finished'
              @redis_1.unsubscribe
            end
          end
        end
      end
      true
    end

    def log(message)
      @logger.info("CLIENT: #{message}")
    end

  end
end