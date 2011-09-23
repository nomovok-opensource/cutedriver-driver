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
  
    attr_reader :command_arguments
  
    # TODO: document me
    def initialize( command, arguments = {} )
        
      arguments.check_type Hash, "wrong argument type $1 for #{ self.class } arguments (expected $2)"  

      # default values
      arguments.default = nil

      @command_arguments = arguments

      @_command = command

      @_application_name = nil
      @_application_uid = nil
      @_sut = nil
      @_arguments = nil
      @_events_to_listen = nil
      @_signals_to_listen = nil
      @_environment = nil
      @_working_directory = nil
      @_flags = nil
      @_start_command = nil
      @_refresh_args = nil
      @_attribute_csv_string = nil
      @_checksum = nil
      
      # store values from arguments - call setter method only when required      
      arguments.each_pair{ | key, value |
      
        # skip if value is nil (default)   
        next if value.nil?
      
        case key
        
          when :application_name
            name( value )
            
          when :application_uid
            uid( value )

          when :sut
            sut( value )
          
          when :arguments
            arguments( value )
          
          when :events_to_listen
            events_to_listen( value )

          when :signals_to_listen
            signals_to_listen( value )

          when :environment
            environment( value )

          when :working_directory
            working_directory( value )
                       
          when :flags
            flags( value )

          when :start_command
            start_command( value ) 

          when :refresh_arguments
            refresh_args( value )

          when :attribute_filter
            attribute_filter( value )

          when :checksum
            @_checksum = value

        else

          # show warning/exception?        
                            
        end
      
      }
      
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

      sut.check_type [ MobyBase::SUT, NilClass ], 'wrong argument type $1 for SUT (expected $2)'
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
    def name( name )    

      name.check_type [ String, NilClass ], 'wrong argument type $1 for application name (expected $2)'
      @_application_name = name    
      self

    end

    def arguments( arguments )

      arguments.check_type [ String, NilClass ], 'wrong argument type $1 for application arguments (expected $2)'
      @_arguments = arguments

    end

    def flags( flags ) 

      flags.check_type [ Hash, NilClass ], 'wrong argument type $1 for application flags (expected $2)'
      @_flags = flags

    end

    def environment( env )

      env.check_type [ String, NilClass ], 'wrong argument type $1 for application environment (expected $2)'
      @_environment = env

    end

    def working_directory( dir )
    
      dir.check_type [ String, NilClass ], 'wrong argument type $1 for application working directory (expected $2)'
      @_working_directory = dir
      
    end

    def events_to_listen( events )

      events.check_type [ String, NilClass ], 'wrong argument type $1 for events to be listened (expected $2)'   
      @_events_to_listen = events

    end

    def signals_to_listen( signals )

      signals.check_type [ String, NilClass ], 'wrong argument type $1 for signals to be listened (expected $2)'
      @_signals_to_listen = signals

    end
    
    def start_command( start_command )

      start_command.check_type [ String, NilClass ], 'wrong argument type $1 for application start command (expected $2)'
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

      app_uid.check_type [ Fixnum, String, NilClass ], 'wrong argument type $1 for application UID (expected $2)'

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
  
  end

end # MobyCommand

