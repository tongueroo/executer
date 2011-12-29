require "timeout"
require "yaml"

gem "yajl-ruby", "~> 1.0.0"
require "yajl"

gem "redis", "~> 2.2.2"
require "redis"

$:.unshift File.dirname(__FILE__)

require 'executer/client'

class Executer

  def initialize(yaml)
    options = YAML.load(File.read(yaml))

    puts "\nStarting executer server (redis @ #{options['redis']})..."

    redis = Redis.connect(:url => "redis://#{options['redis']}")
    retries = 0
    
    begin
      while true
        if request = redis.lpop('executer:request')
          Timeout.timeout(60*60) do
            request = Yajl::Parser.parse(request)
            `#{request['cmd']}`
            redis.publish(
              "executer:response:#{request['id']}",
              "finished"
            )
          end
        end

        sleep(1.0 / 1000.0)
      end
    rescue Interrupt
      shut_down
    rescue Exception => e
      puts "\nError: #{e.message}"
      puts "\t#{e.backtrace.join("\n\t")}"
      retries += 1
      shut_down if retries >= 10
      retry
    end
  end

  def shut_down
    puts "\nShutting down executer server..."
    exit
  end
end