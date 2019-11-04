module Mavenlink
  class Logger < ::Logger
    # @todo(SZ) YARD, docu, describe colors, when to use each one

    # @param device [nil, STDOUT, STDERR]
    def initialize(device)
      super
      self.level = Logger::FATAL
    end

    # @param [String] message
    def disappointment(message)
      info("\e[35m[Maven]\e[0m \e[31m#{message}\e[0m") if error?
    end

    # @param [String] message
    def hint(message)
      info("\e[32m[Maven]\e[1m \e[33m#{message}\e[0m") if warn?
    end

    # @param [String] message
    def note(message)
      info("\e[32m[Maven]\e[0m \e[36m#{message}\e[0m") if info?
    end

    # @param [String] message
    def whisper(message)
      info("\e[32m[Maven]\e[0m \e[37m#{message}\e[0m") if debug?
    end

    # @param [String] message
    def inspection(message)
      return unless debug?

      if message.respond_to?(:awesome_inspect)
        info(message.awesome_inspect)
      else
        info(message.inspect)
      end
    end

    # @param [String] message
    def self.disappointment(message)
      Mavenlink.logger.disappointment(message)
    end

    # @param [String] message
    def self.hint(message)
      Mavenlink.logger.hint(message)
    end

    # @param [String] message
    def self.note(message)
      Mavenlink.logger.note(message)
    end

    # @param [String] message
    def self.whisper(message)
      Mavenlink.logger.whisper(message)
    end
  end
end
