require "timeout"
require "yaml"
require "logger"

gem "yajl-ruby", "~> 1.0.0"
require "yajl"

gem "redis", "~> 2.2.2"
require "redis"

$:.unshift File.dirname(__FILE__)

require 'executer/client'
require 'executer/logger'

class Executer

  def initialize(yaml)
    options = YAML.load(File.read(yaml))

    @logger = Logger.new(options['log'] || '/var/log/executer.log')
    log "Starting executer server (redis @ #{options['redis']})."
    log "Logging to stdout and #{options['log']}..."

    redis = Redis.connect(:url => "redis://#{options['redis']}")
    retries = 0
    
    begin
      while true
        if request = redis.lpop('executer:request')
          Timeout.timeout(60*60) do
            request = Yajl::Parser.parse(request)
            log("Running #{request.inspect}")
            system(request['cmd'])
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
      log "Error: #{e.message}"
      log "\t#{e.backtrace.join("\n\t")}"
      retries += 1
      shut_down if retries >= 10
      retry
    end
  end

  def log(message)
    @logger.info("SERVER: #{message}")
  end

  def shut_down
    log "Shutting down executer server..."
    exit
  end
end