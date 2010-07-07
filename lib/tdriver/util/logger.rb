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

require 'log4r'
require 'log4r/configurator'

module MobyUtil

	class Logger

		include Singleton

		attr_reader :include_behaviour_info

		def initialize()

			# Allow all levels to be reported - do not change this!
			@custom_levels = ['debug', 'behaviour', 'info', 'warning', 'error', 'fatal']

			Log4r::Configurator.custom_levels( *@custom_levels.collect{ | level | level.upcase } )

			Log4r::Logger.root.level = Log4r::DEBUG

			@enabled_stack = [ false ]

			@logger_instance = nil

		end

		def include_behaviour_info=( value )

			raise ArgumentError.new( "Unexpected variable type (%s) for 'include_behaviour_info' boolean, expected TrueClass or FalseClass" ) unless [ TrueClass, FalseClass ].include?( value.class )

			@include_behaviour_info = value

		end

		# allow reporting by passing level as method name, raise exception if method_id not found in @custom_levels array
		def method_missing( method_id, *method_arguments )

			super unless @custom_levels.include?( method_id.to_s )

			self.log( method_id.to_s, *method_arguments )

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

			Log4r::Logger.root.level = report_level

		end

		# TODO: add documentation
		def new_logger( logger_name )

			Log4r::Logger.new( logger_name )

		end

		# TODO: add documentation
		def get_logger( logger_name )

			begin

				Log4r::Logger.get( logger_name )

			rescue

				Kernel::raise ArgumentError.new( "Logger '%s' not found" % logger_name )

			end

		end

		# TODO: add documentation
		def create_outputter( outputter_class, *args )

			outputter_class.new( *args ) 

		end

		# TODO: add documentation
		def add_outputter( logger_instance, outputter_instance )

			logger_instance.add( outputter_instance )

		end

		# TODO: add documentation
		def remove_outputter( logger_instance, outputter_instance )

			logger_instance.remove( outputter_instance )

		end

		# TODO: add documentation
		def set_outputter_pattern( outputter_instance, pattern )

			# Allow only FileOutputter instances
			Kernel::raise ArgumentError.new("Outputter instance not valid") if ![ Log4r::FileOutputter ].include?( outputter_instance.class )

			# Allow only FileOutputter instances
			Kernel::raise ArgumentError.new("Outputter pattern not valid, %M required by minimum") if !/\%M/.match( pattern ) 

			# create pattern for outputter
			outputter_instance.formatter = Log4r::PatternFormatter.new( :pattern => pattern )

		end

		# TODO: add documentation
		# return logger instance
		def self.[]( key )

			self.instance.get_logger( key )

		end

		# TODO: add documentation
		def root

			Log4r::Logger.global

		end

		# TODO: add documentation
		def log( level, *text_array )

			if self.enabled && @logger_instance

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

					

					@logger_instance.send( level, ( include_behaviour_info && !text.empty? ) ? ( "%s in %s" % [ text, log_caller ] ) : ( "%s" % text ) ) 

				} 

			end

		end

		def enable_raise_hooking

			def Kernel::raise( exception )

				begin

					super( exception )

				rescue => ex

					ex.backtrace.slice!( 0 )

					warn_array = [ '', "(%s) %s" % [ ex.class, ex.message.split("\n") ], '', ex.backtrace, '' ].flatten

					MobyUtil::Logger.instance.log( 'warning', *warn_array )

					super( ex )

				end

			end

		end

		# TODO: add documentation
		def enable_logging

			logging_level = Parameter[ :logging_level, nil ]

			return nil if logging_level.nil?

			Kernel::raise RuntimeError.new( "Wrong logging level format '%s' (Expected: %s)" % [ logging_level, "Numeric string"] ) unless MobyUtil::StringHelper.numeric?( logging_level )      

			logging_level = logging_level.to_i

			Kernel::raise RuntimeError.new( "Invalid logging level '%s' (Expected: %s)" % [ logging_level, "0..5"] ) unless (0..5).include?( logging_level.to_i )

			@include_behaviour_info = ( MobyUtil::Parameter[ :logging_include_behaviour_info, 'false' ].downcase == 'true' )

			unless logging_level.zero?

				# create new logger instance
				MobyUtil::Logger.instance.new_logger( 'TDriver' )

				# get logger object reference
				@logger_instance = get_logger( 'TDriver' )

				# create unique name for logfile or use default (TDriver.log)
				filename = ( MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_unique_filename ] ) ? "TDriver_%i.log" % Time.now : "TDriver.log" )

				# logger output path
				outputter_path = MobyUtil::FileHelper.expand_path( MobyUtil::Parameter[ :logging_outputter_path ] )

				# create outputter folder if not exist
				MobyUtil::FileHelper.mkdir_path( outputter_path )

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

				# debug logging
				if ( logging_level == 1 )

					# enable exception capturing on debug level
					enable_raise_hooking

					# pass logger instance to hooking module
					MobyUtil::Hooking.instance.set_logger_instance( MobyUtil::Logger.instance )

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

			#STDOUT.puts "Use MobyUtil::Hooking instead of MobyUtil::Logging when calling hook_methods (#{ caller(1).first })"

			MobyUtil::Hooking.instance.hook_methods( _base ) #if @enabled

		end

	end # Logger
  
end # MobyUtil
