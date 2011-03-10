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

module MobyBehaviour

  # == description
  # Describes the behaviour of application and its associated methods
  #
  # == behaviour
  # GenericApplication
  #
  # == requires
  # *
  #
  # == input_type
  # *
  #
  # == sut_type
  # *
  #
  # == sut_version
  # *
  #
  # == objects
  # application
  #
  module Application

    include MobyBehaviour::Behaviour

    # == description
    # Closes application and optionally verifies that it is closed. A Hash argument can be used to set any of the optional parameters. Keys not set in the hash will use default values. Close can be set to force kill the application process if close fails. It can also be set to not check if the application process is terminated, in which case close is considered to be successful if the application is no longer in the foreground.\n
    # \n
    # [b]NOTE:[/b] this will currently always try to close applications, also privilegied applications. \n
    # \n
    # [b]For backwards compatibility:[/b] Instead of using a Hash as argument, the value can also be true, false or nil which will be taken as the value of :force_kill
    #    
    # == arguments
    # options_hash
    #  Hash
    #   description: See supported hash keys from [link="#close_hash_keys"]close application options hash keys table[/link] 
    #   example: {:force_kill => true, :check_process => false}
    #  TrueClass
    #   description: For backwards compatibility: same as :force_kill => true   
    #   example: true
    #  FalseClass
    #   description: For backwards compatibility: same as :force_kill => false 
    #   example: false
    #  NilClass
    #   description: For backwards compatibility: same as :force_kill => nil (uses 'application_close_kill' from TDriver parameters file)
    #   example: nil
    #
    # == tables
    # close_hash_keys
    #  title: Close application options hash keys
    #  |Key|Type|Description|Default|Required|
    #  |:force_kill|TrueClass, FalseClass|If this options is set to true, the application process is killed if close fails. Setting this option to nil (default value), will cause close to use the value defined in the 'application_close_kill' parameter as defined in the TDriver parameter file.|nil|No|
    #  |:check_process|TrueClass, FalseClass|If this options is set to true, success of the close method is verified by checking if the process is still active. If it is set to false, TDriver will only check that the application is no longer in the foreground.|true|No|
    #
    # == returns
    # NilClass
    #  description: -
    #  example: -
    #
    # == exceptions
    # TestObjectNotFoundError
    #  description: If this application is not the foreground application on the device under test.
    #
    # VerificationError
    #  description: If no application test object is found after close or if this application is still in the foreground after the close.
    #
    # TypeError
    #  description: Wrong argument type %s for options_hash (expected a Hash, TrueClass or FalseClass)
    #
    # TypeError
    #  description: Wrong argument type %s for :force_kill (expected NilClass, TrueClass or FalseClass)
    #
    # TypeError
    #  description: Wrong argument type %s for :check_process (expected TrueClass or FalseClass)
    #
    def close( options_hash = {} )

      begin
        
        # check if closable
        Kernel::raise RuntimeError( "The application is of a type that cannot be closed." ) unless self.closable?
        
        default_options = { :force_kill => nil, :check_process => true }
                
        if options_hash.kind_of?( Hash )

          close_options = default_options.merge( options_hash )

        else

          # support legacy option of defining only force_kill
          close_options = default_options

          if options_hash != nil

            # verify options_hash value
            options_hash.check_type( [ Hash, FalseClass, TrueClass ], "Wrong argument type $1 for options hash (expected $2)" )

            close_options[ :force_kill ] = options_hash

          end

        end
        
        # verify :force_kill variable type
        close_options[ :force_kill ].check_type( [ NilClass, TrueClass, FalseClass ], "Wrong argument type $1 for :force_kill (expected $2)" )

        # verify :check_process variable type
        close_options[ :check_process ].check_type( [ TrueClass, FalseClass ], "Wrong argument type $1 for :check_process (expected $2)" )
        
        if close_options[ :force_kill ] != nil                

          @sut.execute_command( 
            MobyCommand::Application.new( 
              :Close,     # command_type
              self.name,  # app_name
              self.uid,   # app_uid
              self.sut,   # sut
              nil,        # arguments
              nil,        # environment
              nil,        # working directory
              nil,        # events_to_listen
              nil,        # signals_to_listen
              {           # flags 
                :force_kill => close_options[ :force_kill ] 
              } 
            )
          )

        else   

          @sut.execute_command( 
            MobyCommand::Application.new( 
              :Close, 
              self.name, 
              self.uid, 
              self.sut
            ) 
          )

        end

        # Disable logging
        original_logger_state = $logger.enabled
        $logger.enabled = false

        # verify close results
        # store start time
          start_time = Time.now
          timeout_time = $parameters[ self.sut.id ][ :application_synchronization_timeout, '60' ].to_f
        begin

          application_identification_hash = { :type => 'application', :id => @id }

          MobyUtil::Retryable.until(
            :timeout => timeout_time,
            :interval => $parameters[ self.sut.id ][ :application_synchronization_retry_interval, '0.25' ].to_f,
            :exception => MobyBase::VerificationError,
            :unless => [MobyBase::TestObjectNotFoundError, MobyBase::ApplicationNotAvailableError] ) {

            # raises MobyBase::ApplicationNotAvailableError if application was not found 
            @sut.refresh( application_identification_hash, [{:className=>"application", :tasId => @id }] )

            # retrieve application object from sut.xml_data
            matches, unused_rule = TDriver::TestObjectAdapter.get_objects( @sut.xml_data, application_identification_hash, true )

            # check if the application is still found or not
            if ( close_options[ :check_process ] == true ) 

              # the application did not close
              raise MobyBase::VerificationError.new, "Verification of close failed. The application that was to be closed is still running." if matches.count > 0 && (Time.now - start_time) >= timeout_time

            elsif ( close_options[ :check_process ] == false )

              if matches.count > 0 
              
                if TDriver::TestObjectAdapter.test_object_element_attribute( matches.first, 'id' ) == @id 

                  # the application was still in the foreground
                  raise MobyBase::VerificationError, "Verification of close failed. The application that was to be closed was still in the foreground."

                else

                  # The foreground application was not the one being closed.
                  raise MobyBase::TestObjectNotFoundError, "The foreground application was not the one being closed (id: #{ @id })."

                end 

              end

            end

            # The application could not be found, break
            break

          }
          
        rescue MobyBase::TestObjectNotFoundError

          # everything ok: application not running anymore

    		rescue MobyBase::ApplicationNotAvailableError

          # everything ok: application not running anymore

        rescue RuntimeError => e
        
          unless ( e.message =~ /The application with Id \d+ is no longer available/ )

            # something unexpected happened during the close, let exception through
            raise e

          end

        ensure

          # restore original state
          $logger.enabled = original_logger_state

        end

      rescue Exception => exception

        $logger.log "behaviour", "FAIL;Failed when closing.;#{ identity };close;"
        Kernel::raise exception

      end

      $logger.log "behaviour", "PASS;Closed successfully.;#{ identity };close;"

      #@sut.application
            
      nil

    end

    # == description
    # Returns executable name (exe) of foreground application
    # == returns
    # String
    #  description: Application's executable name
    #  example: "calculator"
    # == exceptions
    # RuntimeError
    #  description: No executable name has been defined for this application.
    # == example
    #  puts @sut.application.executable_name #prints foreground executable name to console
    def executable_name

      begin

        exe_name = self.attribute( 'FullName' ).to_s

      rescue MobyBase::AttributeNotFoundError

        begin

          exe_name = self.attribute( 'exepath' ).to_s

        rescue MobyBase::AttributeNotFoundError

          exe_name = ""

        end

      end

      Kernel::raise RuntimeError.new( "Application does not have 'FullName' or 'exepath' attribute defined" ) if exe_name.empty?

      File.basename( exe_name.gsub( /\\/, '/' ) )

    end

    # == description
    # Returns uid of foreground application
    # == returns
    # String
    #  description: Unique ID of the application.
    #  example: "2197"
    # == example
    #  puts @sut.application.uid #prints foreground executable uid to console
    def uid

      id

    end

    # == nodoc
    # TODO: document all the possible values and then make public    
    def environment
    
      @environment
      
    end
    
    # == nodoc
    # TODO: to be removed?
    # == description
    # Indicates whether this application can be closed with the ApplicationBehaviour::close method. Note: at the moment
    # it always returns true!
    # === returns
    # Boolean:: True if closing is possible with the ApplicationBehaviour::close method
    # === example
    #  puts @sut.application.closable #prints foreground application closable status to console (at the moment always true)
    def closable?

      #file, line = caller.first.split(":")
      #$stderr.puts "%s:%s warning: TestObject#closable? is deprecated" % [ file, line ]

      true

    end

	    
	# == description
	# Bring the application to foreground.\n
	# \n
	# [b]NOTE:[/b] Currently this works only for Symbian OS target!
	# 
	# == returns
	# NilClass
	#   description: -
	#   example: -
	#
	#
	def bring_to_foreground
	  @sut.execute_command(MobyCommand::Application.new(:BringToForeground, nil, self.uid, self.sut))
	end


	# == description
	# Kills the application process
	# 
	# == returns
	# NilClass
	#   description: -
	#   example: -
	#
	def kill

	  @sut.execute_command( MobyCommand::Application.new( :Kill, self.executable_name, self.uid, self.sut ) )

	end

	# == description
	# Returns the mem usage of the application if the information is available.
	# Will return -1 if the information is not available.
	# 
	# == returns
	# Integer
	#   description: Current memory usage
	#   example: 124354
	#
	def mem_usage
	  mem = -1
	  begin
		mem = self.attribute('memUsage')
	  rescue
	  end
	  mem
	end


    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ApplicationBehaviour

end # MobyBehaviour
