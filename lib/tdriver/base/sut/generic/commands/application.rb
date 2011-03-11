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


module MobyCommand

	class Application < MobyCommand::CommandData

		#TODO: Team TE review @ Wheels
		#Application command types 
		#Launch application = :Run 
		#Close application = :Close 
		#List of running applications = :List
		#Current state of the UI = :State
		#Kill = :Kill
		#Kill All = :KillAll
		#
		# Constructs a new Application CommandData object
		# == params
		# command_type:: (optional) Symbol, defines the command to perform on the application
		# app_name:: (optional) String, name of application to perform this command on
		# app_uid::
		# sut:: (optional) SUT, creator of the command. Can be used to access parameters when creating messages.
		# arguments:: (optional) Arguments given to the application on start up. Comma separated list if more the one.
		# environment:: (optional) Environment given to the application on start up. Comma separated list if more the one.
		# working_directory:: (optional) Working directory for the application (not used on Symbian)
		# == returns
		# Application:: New CommandData object
		# == raises
		# ArgumentError:: When the supplied command_type is invalid.
		def initialize( command_type = nil, app_name = nil, app_uid = nil, sut = nil, arguments = nil, environment = nil, working_directory = nil, events_to_listen = nil, signals_to_listen = nil, flags = nil, start_command = nil)
			# Set status value to nil (not executed)

			self.command( command_type )
			self.name( app_name )
			self.uid( app_uid )    
			self.sut( sut )
			self.arguments( arguments )
			self.events_to_listen( events_to_listen )
			self.signals_to_listen( signals_to_listen )
			self.environment( environment )
			self.working_directory( working_directory )
			self.flags( flags )
			self.start_command( start_command )
		    self.refresh_args

			@_attribute_csv_string = nil

			self

		end

		# Store the args for possible future use
		def refresh_args(refresh_args={})
		  @_refresh_args = refresh_args
		end
		
		def get_refresh_args
		  @_refresh_args
		end


		# Defines the type of command this Application CommandData object represents
		# == params
		# command_type:: Symbol, defines the command to perform on the application
		# == returns
		# Application:: This CommandData object
		# == raises
		# ArgumentError:: When the supplied command_type is invalid.
		def command( command_type )        

			@_command = command_type
			self    

		end  

		# Defines the used SUT to be able to access parameters when creating messages
		# == params
		# sut:: SUT, creator of the command.
		# == returns
		# Application:: This CommandData object
		# == raises
		# ArgumentError:: When sut is not nil or a SUT
		def sut( sut )

			raise ArgumentError.new( "The given sut must be nil or a SUT." ) unless sut == nil || sut.kind_of?( MobyBase::SUT )
			@_sut = sut
			self

		end

		# Defines the name of the application this Application CommandData object is associated with
		# == params
		# app_name:: String, name of application to perform this command on
		# == returns
		# Application:: This CommandData object
		# == raises
		# ArgumentError:: When app_name is not nil or a String
		def name( app_name )    

			raise ArgumentError.new( "The given application name must be nil or a String." ) unless app_name == nil || app_name.kind_of?( String )        
			@_application_name = app_name    
			self

		end

		def arguments( arguments )

			raise ArgumentError.new( "The given application arguments must be nil or a String." ) unless arguments == nil || arguments.kind_of?( String )   
			@_arguments = arguments

		end

		def flags( flags ) 

			raise ArgumentError.new( "The given application flags must be nil or a Hash." ) unless flags == nil || flags.kind_of?( Hash )   
			@_flags = flags

		end

		def environment( environment )

			raise ArgumentError.new( "The given application environment must be nil or a String." ) unless environment == nil || environment.kind_of?( String )   
			@_environment = environment

		end

		def working_directory( working_directory )
		
			raise ArgumentError.new( "The given application working directory must be nil or a String." ) unless working_directory == nil || working_directory.kind_of?( String )
			@_working_directory = working_directory
			
		end

		def events_to_listen( events )

			raise ArgumentError.new( "The events to listen must be nil or a String." ) unless events == nil || events.kind_of?( String )   
			@_events_to_listen = events

		end

		def signals_to_listen( signals )

			raise ArgumentError.new( "The signals to listen must be nil or a String." ) unless signals == nil || signals.kind_of?( String )   
			@_signals_to_listen = signals

		end
		
		def start_command( start_command )

			raise ArgumentError.new( "The start_command must be nil or a String." ) unless start_command == nil || start_command.kind_of?( String )   
			@_start_command = start_command

		end

		# Defines the uid of the application this Application CommandData object is associated with
		# == params
		# app_uid:: FixNum, uid of application to perform this command on
		# == returns
		# Application:: This CommandData object
		# == raises
		# ArgumentError:: When app_name is not nil or a String
		def uid( app_uid )       

			raise ArgumentError.new( "The given application uid must be nil, a String or an Integer." ) unless app_uid == nil || app_uid.kind_of?( String ) || app_uid.kind_of?( Fixnum )
			@_application_uid = app_uid
			@_application_uid = @_application_uid.to_i unless @_application_uid == nil    
			self    

		end

		def get_command

			@_command

		end

		def get_application

			@_application_name

		end

		def get_uid

			@_application_uid

		end

		def get_flags

			@_flags

		end

		def attribute_filter(attribute_string)

			@_attribute_csv_string = attribute_string

		end

		def get_attribute_filter

			@_attribute_csv_string

		end

		# enable hooking for performance measurement & debug logging
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # Application

end # MobyCommand
