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

		attr_accessor :enabled

		def initialize()
			# Allow all levels to be reported - do not change this!
			Log4r::Configurator.custom_levels('DEBUG', 'BEHAVIOUR', 'INFO', 'WARNING', 'ERROR', 'FATAL')
			Log4r::Logger.root.level = Log4r::DEBUG
			@enabled = false
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

			begin
        log_caller=caller.first
				# convert to lowercase string
				level = level.to_s.downcase

				# get logger instance
				logger_instance = get_logger( 'TDriver' )

				# log text to given level if logging enabled
				text_array.each{ | text |          
					if Parameter[ :logging_include_behaviour_info, 'false' ] == 'true'
					  logger_instance.send( level, "#{text.to_s} in #{log_caller}" ) 
					else
					  logger_instance.send( level, "#{text.to_s}" ) 
					end
				} 

			end if @enabled

		end

		def enable_raise_hooking()

			def Kernel::raise( exception )
				begin
					super( exception )
				rescue => ex
					ex.backtrace.slice!( 0 )
					warn_array = [ '', "(#{ ex.class }) #{ ex.message.split("\n") }", '', ex.backtrace, '' ].flatten
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
			Kernel::raise RuntimeError.new( "Invalid logging level '%s' (Expected: %s)" % [ logging_level, "0..5"] ) unless (0..5).include?( logging_level.to_i )

			logging_level = logging_level.to_i

			if ( logging_level > 0 )

				# create new logger instance
				MobyUtil::Logger.instance.new_logger( 'TDriver' )

				# create unique name for logfile or use default (TDriver.log)
				filename = ( MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_unique_filename ] ) ? "TDriver_#{ Time.now.to_i }.log" : "TDriver.log" )

				# create outputter folder if not exist
				MobyUtil::FileHelper.mkdir_path( 
					MobyUtil::FileHelper.expand_path( 
						Parameter[ :logging_outputter_path ] 
					) 
				)

				# check if outputter is enabled
				if MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_enabled ] )

					# create new outputter instance type of FileOutputter
					outputter = MobyUtil::Logger.instance.create_outputter( 
						Log4r::FileOutputter, 
						"TDriver_LOG", 
						:filename => MobyUtil::FileHelper.expand_path( "#{ Parameter[ :logging_outputter_path ] }/#{ filename }" ), 
						:trunc => MobyUtil::StringHelper.to_boolean( Parameter[ :logging_outputter_append ] ) == false, 
						:level => logging_level
					) 

					# set outputter log event write pattern
					MobyUtil::Logger.instance.set_outputter_pattern( outputter, Parameter[ :logging_outputter_pattern ] )

					# add outputter to logger instance
					MobyUtil::Logger.instance.add_outputter( MobyUtil::Logger[ 'TDriver' ], outputter )

				end

				# pass logger instance to hooking class if method call debug logging enabled 
				#MobyUtil::Hooking.instance.set_logger_instance( MobyUtil::Logger.instance ) if Parameter[ :logging ][ :level ].to_i == 1

				if ( logging_level == 1 )
					#enable_raise_hooking(); 
					MobyUtil::Hooking.instance.set_logger_instance( MobyUtil::Logger.instance ) 
				end  

				# change logger status
				@enabled = true

				# log event: start logging
			        MobyUtil::Logger.instance.log( 'info' , "", "Logging started at #{ Time.now.to_s }", "" )

			end

			report_status_at_exit

		end

		def report_status_at_exit

			at_exit{

				begin
					exit_status = nil

					case $!

						when NilClass
							exit_status = ['info', 'Execution finished succesfully']

						when SystemExit
							exit_status = ['info', 'Execution terminated by system exit' ]

					else

						exit_status = ['error', "Execution terminated with exception: #{ caller.first }: #{ $!.message.split("\n") }"]

					end

					MobyUtil::Logger.instance.log( *exit_status )

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
