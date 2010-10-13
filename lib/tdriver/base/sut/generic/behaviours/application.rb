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


# Application behaviour
#
# Describes the behaviour of application and its associated methods
#
module MobyBehaviour

	module Application

		include MobyBehaviour::Behaviour

		# Closes application
		#
		# Closes the application whether or not it is on foreground. Note: this will currently always try to close applications, also
		# privilegied applications
		#
		# == params
		#options_hash:: Hash, possible keys :force_kill (default nil) and :check_proces (default true). 
		#For backwards compatibility: instead of a Hash, the value can also be true, false or nil, in which case it is taken as the value of :force_kill
		#:force_kill:: If key is set to true, the application process is killed if close fails.  If set to nil, value of key will be  taken  as defined 
		#by 'application_close_kill' parameter in the TDriver parameter file.
		#:check_process:: If key is set to true, success of the close method is verified by checking if the process is still active. If set to false, 
		#TDriver will only check that the application is no longer in the foreground.	  
		#
		# === raises
		# TestObjectNotFoundError:: If this application is not the foreground application on the device under test.
		# VerificationError:: If no application test object is found after close or if this application is still in the foreground after the close.
		# ArgumentError:: Options_hash was not a Hash or one of the keys had an invalid type.
		# === example
		#  @sut.application.close #closes anonymous foreground application
		#
		#  @mce_app = @sut.run(:name => 'Mce.exe') # launches mce app
		#  @mce_app.close # closes above launched mce-application and verifies that correct application was closed
		def close( options_hash = {} )

			begin
				
				# check if closable
				Kernel::raise RuntimeError( "The application is of a type that cannot be closed." ) unless self.closable?
				
				default_options = { :force_kill => nil, :check_process => true }
								
				if options_hash.kind_of? Hash
				  close_options = default_options.merge options_hash
				else
				  # support legacy option of defining only force_kill
				  close_options = default_options
				  if options_hash!=nil
                    #check that old force_kill_close argument is equal to true or false
                    Kernel::raise ArgumentError.new( "Incorrect value for argument options_hash, expected a Hash or a bool 'true' or 'false'"  ) unless options_hash==true or options_hash==false
				    close_options[ :force_kill ] = options_hash
				  end				  
				end
				
				raise ArgumentError.new "The options_hash :force_kill key must be true or false if it is defined, the used value was \"#{close_options[ :force_kill ]}\"." unless [nil, true, false].include? close_options[ :force_kill ]
				raise ArgumentError.new "The options_hash :check_process key must be true or false if it is defined, the used value was \"#{close_options[ :check_process ]}\"." unless [true, false].include? close_options[ :check_process ]
				
                if close_options[ :force_kill ] != nil                
                  flags_hash = { }
                  flags_hash[ :force_kill ] = close_options[ :force_kill ]
                  #execute_command( command_type = nil, app_name = nil, app_uid = nil, sut = nil, arguments = nil, environment = nil, events_to_listen = nil, signals_to_listen = nil, flags = nil)
                  @sut.execute_command( MobyCommand::Application.new( :Close, self.name, self.uid, self.sut, nil, nil, nil, nil, flags_hash) )
                else   
                  @sut.execute_command( MobyCommand::Application.new( :Close, self.name, self.uid, self.sut, nil ) )
                end

                # Disable logging
				MobyUtil::Logger.instance.enabled = false if ( original_logger_state = MobyUtil::Logger.instance.enabled )

				# verify close results
				begin

					MobyUtil::Retryable.until(
						:timeout => MobyUtil::Parameter[ self.sut.id ][ :application_synchronization_timeout, '60' ].to_f,
						:interval => MobyUtil::Parameter[ self.sut.id ][ :application_synchronization_retry_interval, '0.25' ].to_f,
						:exception => MobyBase::VerificationError,
						:unless => MobyBase::TestObjectNotFoundError ) {

						# check if the application is still found or not
						if ( close_options[ :check_process ] == true and @sut.application( :id => self.uid, :__timeout => 0 ) )

							# the application did not close
							raise MobyBase::VerificationError.new("Verification of close failed. The application that was to be closed is still running.")
							
						elsif ( close_options[ :check_process ] == false )

						    if @sut.application( :__timeout => 0 ).uid == self.uid 						
							  # the application was still in the foreground
							  raise MobyBase::VerificationError.new("Verification of close failed. The application that was to be closed was still in the foreground.")
							else
							  # The foreground application was not the one being closed.
							  raise MobyBase::TestObjectNotFoundError.new( "The foreground application was not the one being closed (id: #{self.uid})." )
							end 

						else
						
							# The application could not be found, break
							break;

						end

					}

				rescue MobyBase::TestObjectNotFoundError

					#puts "app.close: sut.application --> test object not found error --> ok --> exit"
					# everything ok: application not running anymore

				rescue RuntimeError => e
				
					
					if (e.message =~ /The application with Id \d+ is no longer available/)
						# everything ok: application not running anymore
					else
						# something unexpected happened during the close, let exception through
						raise e
					end



				ensure

					# restore original state
					MobyUtil::Logger.instance.enabled = original_logger_state
				end

			rescue Exception => exception

				#puts "app.close: close app failed --> exit "

				MobyUtil::Logger.instance.log "behaviour", "FAIL;Failed when closing.;#{ identity };close;"
				Kernel::raise exception

			end

			#puts "app.close: close app passed --> exit "

			MobyUtil::Logger.instance.log "behaviour", "PASS;Closed successfully.;#{ identity };close;"
      @sut.refresh
      nil

		end

		# Returns executable name (exe) of foreground application
		#
		# === returns
		# String:: Name(exe) of the application.
		# === raises
		# RuntimeError:: No executable name has been defined for this application.
		# === example
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

			Kernel::raise RuntimeError.new( "No executable full name has been defined for this application." ) if exe_name.empty?

			File.basename( exe_name.gsub( /\\/, '/' ) )

		end

		# Returns uid of foreground application
		#
		# === returns
		# String:: UID of the application.		
		# === example
		#  puts @sut.application.uid #prints foreground executable uid to console
		def uid

			id

		end

		# Indicates whether this application can be closed with the ApplicationBehaviour::close method. Note: at the moment
		# it always returns true!
		# === returns
		# Boolean:: True if closing is possible with the ApplicationBehaviour::close method
		# === example
		#  puts @sut.application.closable #prints foreground application closable status to console (at the moment always true)
		def closable?

			true

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ApplicationBehaviour

end # MobyBehaviour
