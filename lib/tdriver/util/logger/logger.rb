############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of Testability Driver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################

module MobyUtil

  class Logger

    include Singleton

    attr_reader :include_behaviour_info

    def initialize

      # Allow all levels to be reported - do not change this!
      @custom_levels = ['debug', 'behaviour', 'info', 'warning', 'error', 'fatal']

      #Log4r::Configurator.custom_levels *@custom_levels.collect{ | level | level.upcase }

      #Log4r::Logger.root.level = Log4r::DEBUG

      @enabled_stack = [ false ]

      @logger_instance = nil

      @logger_engine_loaded = false

    end

    def include_behaviour_info=( value )

      value.check_type( [ TrueClass, FalseClass ], "wrong argument type $1 for include_behaviour_info (expected $2)" )

      @include_behaviour_info = value

    end

    # allow reporting by passing level as method name, raise exception if method_id not found in @custom_levels array
    def method_missing( method_id, *method_arguments )

      method_id_str = method_id.to_s

      if @custom_levels.include?( method_id_str )

        log method_id_str, *method_arguments

      else

        # raise exception
        super

      end

    end

    # TODO: add documentation
    def enabled

      @enabled_stack[ -1 ]

    end

    # TODO: add documentation
    def enabled=( value )

      @enabled_stack[ -1 ] = value

    end

    # TODO: add documentation
    def push_enabled( value )

      # push current value to stack if given argument is other than boolean
      value = @enabled_stack[ -1 ] unless [ TrueClass, FalseClass ].include?( value.class )

      @enabled_stack << value

    end

    # TODO: add documentation
    def pop_enabled

      @enabled_stack.pop if @enabled_stack.count > 1

    end

    # TODO: add documentation
    def set_report_level( report_level )

      if @logger_engine_loaded

        Log4r::Logger.root.level = report_level

      else

        nil

      end

    end

    # TODO: add documentation
    def new_logger( logger_name )

      if @logger_engine_loaded

        Log4r::Logger.new( logger_name )

      else

        nil

      end

    end

    # TODO: add documentation
    def get_logger( logger_name )

      begin

        if @logger_engine_loaded

          Log4r::Logger.get( logger_name )

        else

          nil

        end

      rescue

        Kernel::raise ArgumentError, "Logger #{ logger_name.inspect } not found"

      end

    end

    # TODO: add documentation
    def create_outputter( outputter_class, *args )

      outputter_class.new *args

    end

    # TODO: add documentation
    def add_outputter( logger_instance, outputter_instance )

      logger_instance.add outputter_instance

    end

    # TODO: add documentation
    def remove_outputter( logger_instance, outputter_instance )

      logger_instance.remove outputter_instance

    end

    # TODO: add documentation
    def set_outputter_pattern( outputter_instance, pattern )

      if @logger_engine_loaded

        # Allow only FileOutputter instances
        Kernel::raise ArgumentError, 'Outputter pattern not valid, %M required by minimum' if !/\%M/.match( pattern ) 

        # create pattern for outputter
        outputter_instance.formatter = Log4r::PatternFormatter.new :pattern => pattern

      end

    end

    # TODO: add documentation
    # return logger instance
    def self.[]( key )

      get_logger key

    end

    # TODO: add documentation
    def root

      if @logger_engine_loaded

        Log4r::Logger.global

      else 

        nil

      end

    end

    # TODO: add documentation
    def log( level, *text_array )

      if @logger_instance && enabled

        # convert to lowercase string
        level = level.to_s.downcase

        include_behaviour_info = @include_behaviour_info 

        # debug log entries and logging by using TDriver.logging.info or MobyUtil::Logging.instance.info etc
        if caller.first =~ /method_missing/

          # get correct caller method
          log_caller = caller.at( 1 )

          # debug level
          if log_caller =~ /hooking\.rb/

            log_caller = caller.at( 3 ).first

          end

        elsif caller.first =~ /logger\.rb/

          # do not add caller info if called from self
          include_behaviour_info = false

        else

          # normal logging, e.g. behaviour logging from method etc
          log_caller = caller.at( 0 )

        end

        # log text to given level if logging enabled
        text_array.each{ | text |

          @logger_instance.send level, ( include_behaviour_info && !text.empty? ) ? "#{ text.to_s } in #{ log_caller.to_s }" : text.to_s

        }

      end

    end

    def enable_raise_hooking

      # hook Kernel.raise
      def Kernel::raise( *exception )

        begin

          super *exception

        rescue => raised_exception

          raised_exception.backtrace.slice!( 0 )

          $logger.log 'warning', *[ '', "(#{ raised_exception.class }) #{ raised_exception.message.split("\n") }", '', raised_exception.backtrace, '' ].flatten

          super raised_exception

        end

      end

    end

    def set_debug_exceptions

      if ARGV.include?( '--debug_exceptions' ) || $parameters[ :debug_exceptions, 'false' ].to_s.downcase == 'true'

        ARGV.delete('--debug_exceptions')

        # for debugging to see every occured exception
        def Kernel.raise( *args )
          #begin
          # raise and catch exception  
          super( *args )
          #rescue
          # remove wrapper call from backtrace 
          # $!.backtrace.shift
          #puts "%s: %s\nBacktrace: \n%s\n\n" % [ $!.class, $!.message, $!.backtrace.collect{ | line | "  %s" % line }.join("\n") ]
          # raise exception again
          # super $!          
          #end
        end

        # hook Object(Kernel)#raise
        ::Object.class_exec{ 

          ::Kernel.module_exec{

            alias_method :original_raise, :raise

            def raise( *args )

              begin

                # raise and catch exception  
                original_raise( *args )

              rescue

                # remove wrapper calls from backtrace
                while $!.backtrace.first =~ /(logger\.rb).*(raise)/
                
                  $!.backtrace.shift
                
                end
                
                puts "[debug] %s: %s\n[debug] Backtrace: \n[debug] %s\n\n" % [ 
                  $!.class, 
                  $!.message, 
                  $!.backtrace.collect{ | line | "  ... from %s" % line }.join("\n[debug] ") 
                ]
                
                # raise exception again
                original_raise $!

              end            

            end
            
          }
        }

      end

    end

    # TODO: add documentation
    def enable_logging

      set_debug_exceptions # if enabled

      # returns logging level as string
      logging_level = $parameters[ :logging_level, nil ]

      # do not enable logging if no logging level is not defined
      return nil if logging_level.nil?

      # raise exception if wrong format for logging level
      Kernel::raise RuntimeError, "Wrong logging level format '#{ logging_level }' defined in TDriver parameter/template XML (expected numeric string)" unless logging_level.numeric?

      # convert to integer
      logging_level = logging_level.to_i

      # raise exception if unsupported logging level
      Kernel::raise RuntimeError, "Unsupported logging level '#{ logging_level }' defined in TDriver parameter/template XML (expected 0..5)" unless ( 0..5 ).include?( logging_level )

      @include_behaviour_info = $parameters[ :logging_include_behaviour_info, 'false' ].to_s.to_boolean

      # UI state XML parse error logging - verify that all required parameters are configured and output folder is created succesfully
      if MobyUtil::KernelHelper.to_boolean( $parameters[ :logging_xml_parse_error_dump, 'false' ] ) == true

        begin

          if $parameters[ :logging_xml_parse_error_dump_path, nil ].nil?

            warn("warning: Configuration parameter :logging_xml_parse_error_dump_path missing, disabling the feature...") 

            # disable feature
            raise ArgumentError

          else

            begin

              # create error dump folder if not exist, used e.g. when xml parse error
              MobyUtil::FileHelper.mkdir_path( MobyUtil::FileHelper.expand_path( $last_parameter ) )

            rescue

              warn("warning: Unable to create log folder #{ $parameters[ :logging_xml_parse_error_dump_path ] } for corrupted XML UI state files")

              # disable feature
              raise ArgumentError

            end

          end

          if $parameters[ :logging_xml_parse_error_dump_overwrite, nil ].nil?

            warn("warning: Configuration parameter :logging_xml_parse_error_dump_overwrite missing, using 'false' as default value")

            $parameters[ :logging_xml_parse_error_dump_overwrite ] = 'false'

          end

        rescue ArgumentError

          # disable xml logging
          $parameters[ :logging_xml_parse_error_dump ] = 'false'

        rescue

          # disable xml logging
          warn( "warning: Disabling logging due to failure (#{ $!.class }: #{ $!.message })" )

          $parameters[ :logging_xml_parse_error_dump ] = 'false'

        end

      else

        warn("warning: Configuration parameter :logging_xml_parse_error_dump missing, disabling the feature...") 
        $parameters[ :logging_xml_parse_error_dump ] = 'false'

      end
      
      unless logging_level.zero?

        # logger output path
        outputter_path = MobyUtil::FileHelper.expand_path( $parameters[ :logging_outputter_path ] )

        require 'log4r'

        require 'log4r/configurator'

        Log4r::Configurator.custom_levels *@custom_levels.collect{ | level | level.upcase }

        Log4r::Logger.root.level = Log4r::DEBUG

        @logger_engine_loaded = true

        # disable logging if exception is raised during 
        begin

          # create outputter folder if not exist
          MobyUtil::FileHelper.mkdir_path( outputter_path )

          # create new logger instance
          new_logger( 'TDriver' )

          # get logger object reference
          @logger_instance = get_logger( 'TDriver' )

          # create unique name for logfile or use default (TDriver.log)
          filename = ( MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_unique_filename ] ) ? "TDriver_#{ Time.now.to_i }.log" : "TDriver.log" )

          # check if outputter is enabled
          if MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_enabled ] )

            # create new outputter instance type of FileOutputter
            outputter = create_outputter(

              # outputter type
              Log4r::FileOutputter, 

              # outputter name
              "TDriver_LOG",

              # outputter filename 
              :filename => File.join( outputter_path, filename ), 

              # append to or truncate file
              :trunc => MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_append ] ) == false, 

              # logging level
              :level => logging_level

            ) 

            # set outputter log event write pattern
            set_outputter_pattern( outputter, Parameter[ :logging_outputter_pattern ] )

            # add outputter to logger instance
            add_outputter( @logger_instance, outputter )

          end
		  
          # Add stdout outputter if set on configuration parameters
          if MobyUtil::StringHelper.to_boolean( Parameter[ :logging_stdout_outputter_enabled ] )
            stdout_outputter = create_outputter(
              Log4r::StdoutOutputter, # outputter type
              "TDriver_LOG_stdout",	# outputter name
              :level => logging_level # logging level
            ) 
            set_outputter_pattern( stdout_outputter, Parameter[ :logging_outputter_pattern ] )
            add_outputter( @logger_instance, stdout_outputter )
          end

        rescue

          $parameters[ :logging_level ] = '0'

          @logger_instance = nil

          @enabled_stack = [ false ]

          warn("warning: Disabling logging due to failure (#{ $!.class }: #{ $!.message })")

          return nil

        end

        # debug logging
        if ( logging_level == 1 )

          # enable exception capturing on debug level
          enable_raise_hooking

          # pass logger instance to hooking module
          TDriver::Hooking.logger_instance = MobyUtil::Logger.instance

        end  

        # enable logging
        @enabled_stack = [ true ]

        # log event: start logging
        log( 'info' , "", "Logging engine started", "" )

      end

      report_status_at_exit

    end

    def report_status_at_exit

      at_exit{

        begin

          exit_status = nil

          case $!

            when NilClass

              exit_status = ['info', '', 'Execution finished succesfully', '']

            when SystemExit

              exit_status = ['info', '', 'Execution terminated by system exit', '' ]

          else

            exit_status = ['error', '', "Execution terminated with exception: %s: %s" % [ caller.first, $!.message.split("\n") ], '' ]

          end

          log( *exit_status )

        rescue

        end

      }
    end

    def hook_methods( _base )

      #STDOUT.puts "Use TDriver::Hooking instead of MobyUtil::Logging.hook_methods (#{ caller(1).first })"

      TDriver::Hooking.hook_methods( _base ) #if @enabled

    end

  end # Logger
  
end # MobyUtil

# set global variable pointing to parameter class
$logger = MobyUtil::Logger.instance
