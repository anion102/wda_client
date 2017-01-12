# encoding: utf-8
# author: anion
require 'logger'
module WdaClient
  module LoggerOut
    LOG_PATH = '/Users/ceshi/Documents/log/log.log'
    class <<self

      def logger

        # stdout log
        $logger = Logger.new(STDOUT)
        #log level set
        $logger.level = Logger::INFO
        #log format set
        $logger.formatter = proc{|severity,datetime,progname,msg|
          "#{severity}: #{datetime}: #{progname}: #{msg}"
        }

        #log file LOG_PATH
        #catch exception
        # fail 'logfile or directory not exist!' unless create_log?
        #
        # file = File.open(LOG_PATH, 10, 102400)
        # $logger_file = Logger.new(file)  #输出文件
        # $logger_file.level = Logger::INFO
        #
        # $logger_file.formatter = proc{|severity,datetime,progname,msg|
        #   "#{severity}: #{datetime}: #{progname}: #{msg}"
        # }

        self
      end

      # put info level log
      # save info level log
      def info_log(progname,msg)
        #stdout
        $logger.info(progname) {msg}
        #file
        # $logger_file.info(progname) {msg}
      end

      # put warn level log
      # save warn level log
      def warn_log(progname,msg)
        $logger.warn(progname) {msg}
        # $logger_file.warn(progname) {msg}
      end

      # put error level log
      # save error level log
      def error_log(progname,msg)
        $logger.error(progname) {msg}
        # $logger_file.error(progname) {msg}
      end

      # create log file for writing
      def create_log?
        #first check directory
        path = LOG_PATH.split('log.log')[0]
        if File.directory?(path)
          #file check
          unless File.exist?(LOG_PATH)
            File.new(LOG_PATH,'w+')
          end
        else
          FileUtils.mkdir(path)
          File.new(LOG_PATH,'w+')
        end

        return File.exist?(LOG_PATH)
      end
    end
  end
end

