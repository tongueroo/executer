class Executer
  class Logger < Logger
    def add(severity, message = nil, progname = nil, &block)
      puts progname
      super
    end
  end
end