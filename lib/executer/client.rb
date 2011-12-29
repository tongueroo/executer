class Executer
  class Client

    attr_reader :redis_1, :redis_2

    def initialize(redis_url)
      @redis_1 = Redis.connect(:url => "redis://#{redis_url}")
      @redis_2 = Redis.connect(:url => "redis://#{redis_url}")
    end

    def run(options)
      id = options[:id]
      options = Yajl::Encoder.encode(options)

      Timeout.timeout(60*60) do
        @redis_1.subscribe("executer:response:#{id}") do |on|
          on.subscribe do |channel, subscriptions|
            @redis_2.rpush "executer:request", options
          end

          on.message do |channel, message|
            if message.include?('finished')
              @redis_1.unsubscribe
            end
          end
        end
      end

      true
    end
  end
end