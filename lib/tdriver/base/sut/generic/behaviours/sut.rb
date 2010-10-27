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
  # Describes the behaviour of SUT, aka the methods that can be used to control SUT
  #
  # == behaviour
  # GenericSut
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
  # *
  #
  module SUT

    include MobyBehaviour::Behaviour

    attr_accessor(

				  :dump_count,                # number of UI dump requests done to current SUT
				  :current_application_id,    # id of the current appication if set
				  :input,                     # the input method used for interacting with this sut as a symbol, eg. :key or :touch.
				  :refresh_tries,             # number of retries for ui dump on error case
				  :refresh_timeout           # timeout between timeout retry

				  )

    attr_reader(

				:xml_data,      # sut xml_data
				:x_path,        # x_path pattern for xml_data
				:ui_type,       # type of the UI used on the sut, ie. s60, qt, windows
				:ui_version,    # version of the ui used on the sut, ie 3.2.3
				:frozen,        # flag that tells if the ui dump getting is disabled
				:xml_data_crc,  # crc of the previous ui state message
				:verify_blocks  # verify blocks              

				)

    #TODO: document
    def connect( id )

      @_sutController.connect( id )

    end

    # Retrieves the total amount of data sent in bytes
    # == examples
    #  @sut.disconnect
    def disconnect

      @_sutController.disconnect

    end

    # Retrieves the total amount of data received in bytes
    # == examples
    #  @sut.disconnect
    def received_data
	  
      @_sutController.received_bytes

    end

    # Retrieves the total amount of data sent in bytes
    # == examples
    #  @sut.sent_data
    def sent_data
      
      @_sutController.sent_bytes

    end

    # function to disable taking ui dumps from target for a moment
    # user must remember to enable ui dumps again using unfreeze
    def freeze

      @frozen = true

    end

    # function to enable taking ui dumps from target
    def unfreeze

      @frozen = false

    end

    # function to get TestObject
    # TODO: Still under construction. Should be able to create single descendant of the SUT
    # Then is Should create path (parent-child-child-child...) until reaching the particular TestObject
    # TODO: Document me when I'm ready
    def get_object( object_id )

      test_object = @test_object_factory.make( self, MobyBase::TestObjectIdentificator.new( object_id ) )

    end

    # Force to use user defined ui state (e.g. for debugging purposes)
    #
    # Freezes the SUT xml_data, until unfreezed or set to nil. 
    # == params
    # xml:: String, MobyUtil::XML::Element or NilClass
    # == examples
    #  @sut.xml_data = "<tasMessage>.....</tasMessage>"
    #  @sut.xml_data = xml_element
	#  @sut.xml_data = nil
    # == raises
    # ArgumentError:: Unexpected argument type (%s) for xml, expected: %s
    def xml_data=( xml )

      if xml.kind_of?( MobyUtil::XML::Element )

        @xml_data = xml

      elsif xml.kind_of?( String )

        @xml_data = MobyUtil::XML.parse_string( xml ).root

      elsif xml.nil?

        @xml_data = nil

        @frozen = false

      else

        Kernel::raise ArgumentError.new( "Unexpected argument type (%s) for xml, expected: %s" % [ xml.class, "MobyUtil::XML::Element or String"] )

      end
	  
      # freeze sut - xml won't be updated unless unfreezed first
      @frozen = true unless xml.nil?

    end

    # Function asks for fresh xml ui data from the device and stores the result
    # == returns
    # MobyUtil::XML::Element:: xml document containing valid xml fragment describing the current state of the device
    def refresh_ui_dump( refresh_args = {}, creation_attributes = [] )

      current_time = Time.now

      if !@frozen && ( @_previous_refresh.nil? || ( current_time - @_previous_refresh ).to_f > @refresh_interval )

        MobyUtil::Retryable.while(
								  :tries => @refresh_tries,
								  :interval => @refresh_interval,
								  :unless => [ MobyBase::ControllerNotFoundError, MobyBase::CommandNotFoundError ] ) {


		  #use find_object if set on and the method exists
		  if MobyUtil::Parameter[ @id ][ :use_find_object, 'false' ] == 'true' and self.methods.include?('find_object')
			new_xml_data, crc = find_object(refresh_args.clone, creation_attributes)
		  else
			app_command = MobyCommand::Application.new( 
													 :State, 
													 ( refresh_args[ :FullName ] || refresh_args[ :name ] ),
													 refresh_args[ :id ], 
													 self 
													 ) 
			#store in case needed
			app_command.refresh_args(refresh_args)
			new_xml_data, crc = execute_command( app_command )
		  end  

		  
		  # remove timestamp from the beginning of tasMessage, parse if not same as previous ui state
		  if ( xml_data_no_timestamp = new_xml_data.split( ">", 2 ).last ) != @last_xml_data

			@xml_data, @childs_updated = MobyUtil::XML.parse_string( new_xml_data ).root, false

			@last_xml_data = xml_data_no_timestamp

		  end


		  #            if ( @xml_data_crc == 0 || crc != @xml_data_crc || crc.nil? )          
		  #              @xml_data, @xml_data_crc, @childs_updated = MobyUtil::XML.parse_string( new_xml_data ).root, crc, false
		  
		  #            end
		  
		  @dump_count += 1
		  
		  @_previous_refresh = current_time

        } 

        
		

      end

      @xml_data = fetch_references( @xml_data )

      @xml_data
      
    end

    # Creates a test object that belongs to this SUT.
    # Usually it is 'Application' TestObject
    # Associates child object as current object's child.
    # and associates self as child object's parent.
    #
    # NOTE:
    # Subsequent calls to SUT#child(rule) always returns reference to same Testobject:
    # a = sut.child(rule) ; b = sut.child(rule) ; a.equal?( b ); # => true
    # note the usage of equal? above instead of normally used eql?. Please refer to Ruby manual for more information.
    #
    # == params
    # hash_rule:: Hash object holding information for identifying which child to create, eg. :type => :application
    # == returns
    # TestObject:: new child test object or reference to existing child
    def child( hash_rule )

      creation_hash = hash_rule.clone

      initial_timeout = @test_object_factory.timeout unless ( custom_timeout = creation_hash.delete( :__timeout ) ).nil?

      logging_enabled = MobyUtil::Logger.instance.enabled
      MobyUtil::Logger.instance.enabled = false if ( creation_hash.delete( :__logging ) == 'false' )

      begin

        @test_object_factory.timeout = custom_timeout unless custom_timeout.nil?
        child_test_object = @test_object_factory.make( self, MobyBase::TestObjectIdentificator.new( creation_hash ) )

      rescue MobyBase::MultipleTestObjectsIdentifiedError => exception

        MobyUtil::Logger.instance.log "behaviour", "FAIL;Multiple child objects matched criteria.;#{ id };sut;{};child;#{ hash_rule.inspect }"
        Kernel::raise exception

      rescue MobyBase::TestObjectNotFoundError => exception

        MobyUtil::Logger.instance.log "behaviour", "FAIL;The child object could not be found.;#{ id };sut;{};child;#{ hash_rule.inspect }"
        Kernel::raise exception

      rescue Exception => exception

        MobyUtil::Logger.instance.log "behaviour", "FAIL;Failed when trying to find child object.;#{ id };sut;{};child;#{ hash_rule.inspect }"
        Kernel::raise exception

      ensure

        @test_object_factory.timeout = initial_timeout unless custom_timeout.nil?
        MobyUtil::Logger.instance.enabled = logging_enabled

      end

      # return already existing child TestObject so that there is references to only one TestObject
      child_test_object.add_parent( self )

      # Type information is stored in a separate member, not in the Hash
      creation_hash.delete( :type )

      @_child_object_cache.each_value do | _child |

        if _child.eql?( child_test_object )

          # Update the attributes that were used to create the child object.
          _child.creation_attributes = creation_hash

          return _child

        end

      end

=begin
		 @_child_objects.each do | _child |

		  if _child.eql? child_test_object

			# Update the attributes that were used to create the child object.
			_child.creation_attributes = creation_hash
			return _child

		  end

		end
=end
      # Store the attributes that were used to create the child object.
      child.creation_attributes = creation_hash

      add_child( child_test_object )

      child_test_object

    end

		# == description
    # Returns a StateObject containing the current state of this test object as XML.
    # The state object is static and thus is not refreshed or synchronized etc.
    # == returns
    # StateObject:: State of this test object
    # == exceptions
    # RuntimeError
    # description: If the xml source for the object is not in initialized
    # == example
    # sut_state = @sut.state #get the state object for the sut
    def state

      # refresh if xml data is empty
      self.refresh({},{}) if @xml_data.empty?

      Kernel::raise RuntimeError.new( "Can not create state object of SUT with id '%s', no XML content or SUT not initialized properly." % @id ) if @xml_data.empty?

      MobyBase::StateObject.new( 

								MobyUtil::XML.parse_string( 

														   "<sut name='sut' type='sut' id='%s'><objects>%s</objects></sut>" % [ @id, xml_data.xpath("tasInfo/object").collect{ | element | element.to_s }.join ]

														   ).root, 
								self 

								)

    end

    # Returns the current foreground application
    #
    # === params
    # attributes:: (optional) Hash defining required expected attributes of the application
    # === returns
    # TestObject:: Current foreground application
    # === raises
    # ArgumentError:: The attributes argument was not a Hash
    # === examples
    #  fg_app = @sut.application # retrieves foreground application info and stores it in fg_app-object
    def application( attributes = {} )

      begin

        raise TypeError.new( "Input parameter not of Type: Hash.\nIt is: #{ attributes.class }" ) unless attributes.kind_of?( Hash )
        get_default_app = attributes.empty?
        attributes[ :type ] = 'application'
        current_application_id = nil if attributes[ :id ].nil?


        app_child = child( attributes )

      rescue Exception => e

        MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to find application.;#{id.to_s};sut;{};application;" << (attributes.kind_of?(Hash) ? attributes.inspect : attributes.class.to_s)
        Kernel::raise e

      end

      MobyUtil::Logger.instance.log "behaviour" , "PASS;Application found.;#{id.to_s};sut;{};application;" << attributes.inspect

      app_child

    end

    # TODO: feature documentation example, feature tests still yet to be done
    # == description
    # Screen capture function to take snapshot of SUTs current display view
    #
    # == arguments
    # arguments
    #  Hash
    #   description: 
    #    Options to be used for screen capture. See [link="#capture_options_table"]Options table[/link] for valid keys
    #   example: ( :Filename => "c:/screen_shot.png" )
    #
    # == tables
    # capture_options_table
    #  title: Options table
    #  |Key|Type|Description|Example|Required|
    #  |:Filename|String|Filename where file is stored: either absolute path or if no path given uses working directory|:Filename => "c:/screen_shot.png"|Yes|
    #
    # == returns
    # NilClass
    #   description: -
    #   example: -    
    #
    # == exceptions
    # ArgumentError
    #   description: Wrong argument type %s (Expected Hash)
    #
    # ArgumentError
    #   description: Symbol %s expected in argument(s)
    #
    # ArgumentError 
    #   description: Invalid string length for output filename: '%s'
    # 
    def capture_screen( arguments )

      begin

        MobyBase::Error.raise( :WrongArgumentType, arguments.class, "Hash" ) unless arguments.kind_of?( Hash )
        MobyBase::Error.raise( :ArgumentSymbolExpected, ":Filename" ) unless arguments.include?( :Filename )
        MobyBase::Error.raise( :WrongArgumentTypeFor, arguments[ :Filename ].class, "output filename", "String" ) unless arguments[:Filename].kind_of?( String )
        MobyBase::Error.raise( :InvalidStringLengthFor, arguments[ :Filename ].length, "output filename", ">=1" ) unless arguments[:Filename].length > 0

        screen_capture_command_object = MobyCommand::ScreenCapture.new()
        screen_capture_command_object.redraw = arguments[ :Redraw ] if arguments[ :Redraw ]
        image_binary = execute_command( screen_capture_command_object )

        File.open( arguments[ :Filename ], 'wb:binary'){ | image_file | image_file << image_binary }

      rescue Exception => e

        MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to capture screen.;#{id.to_s};sut;{};capture_screen;" << (arguments.kind_of?( Hash ) ? arguments.inspect : arguments.class.to_s )
        Kernel::raise e

      end

      MobyUtil::Logger.instance.log "behaviour" , "PASS;Screen was captured successfully.;#{id.to_s};sut;{};capture_screen;" << arguments.inspect

      nil

    end

    # Instructs the SUT to start the specified application if it is not currenly being executed
    # The application will also be brought to the foregound.
    # === params
    # target:: Hash, used to indetify the application to be executed. All symbols defined in the hash
    # must match with the launched application.
    # The following symbols can be defined in the hash, at least one them must be included:
    # [:uid] = String or Integer, uid of the application (268458181)
    # [:name] = String, executable name of the application ('Mce.exe')
    # [:arguments] = Comma separated list of arguments passed to application when starting. ('--nogui,-v')
    # Examples:
    #  @sut.run(:name => 'Mce.exe')
    #  @sut.run(:name => 'Mce.exe', :uid => 268458181)
    #  @sut.run(:name => 'demoapp.exe', :arguments => '--nogui')
    # === returns
    # TestObject:: Test object of the started application
    # === raises
    # ArgumentError:: If no Hash is provided as argument or the Hash does not contain at least a valid :uid or :name
    # VerificationError:: If no application test object can be found after starting the application, or the found object does not match the launched application
    def run( target )

      begin
        # set the refresh interval to zero while the application is launched
        #orig_interval = MobyUtil::Parameter[ @id ][ :refresh_interval ]
        #MobyUtil::Parameter[ @id ][ :refresh_interval ] = '0'

        # raise exception if argument type other than hash
        Kernel::raise ArgumentError.new( "Wrong argument type %s) for %s (Expected: %s)" % [ target.class, "run method", "Hash" ]) unless target.instance_of?( Hash )

        # default value for keys that does not exist in hash
        target.default = nil

        Kernel::raise ArgumentError.new( "Argument hash must contain at least :uid or :name" ) unless target[ :uid ] || target[ :name ]

        # nils are valid arguments here, at least one of :name, :id has been verified to not be nil
        # ArgumentError is raised by MobyCommnand::Application if the parameters are not valid
        sleep_time = target[ :sleep_after_launch ].to_i #( target[ :sleep_after_launch ] == nil ? 0 : target[ :sleep_after_launch ].to_i)

        #Kernel::raise ArgumentError.new( "Sleep time need to be Integer >= 0" ) unless sleep_time.kind_of? Numeric #instance_of?( Fixnum )
        Kernel::raise ArgumentError.new( "Sleep time need to be >= 0" ) unless sleep_time >= 0


        # try to find an existing app with the current arguments
        if target[ :try_attach ]

          app_list = MobyBase::StateObject.new( self.list_apps() )

          # either ID or NAME have been passed to identify the application
          # raise exception if more than one app has been found for this id/name
          # otherwhise attempt to get the application test object
          app_info = find_app(app_list, {:id => target[ :uid ]}) if target[ :uid ] != nil
          app_info = find_app(app_list, {:name => target[ :name ]}) unless app_info
          app = self.application(:id => app_info.id) if app_info
          if app
			begin
			  app.bring_to_foreground
			rescue Exception => e
			  MobyUtil::Logger.instance.log "WARNING", "Could not bring app to foreground"
			end
			return app
          end
        end

        if ( target[ :start_command ] != nil )
          Kernel::raise MobyBase::BehaviourError.new("Run", "Failed to load execute_shell_method") unless self.respond_to?("execute_shell_command")
          execute_shell_command( target[ :start_command ], :detached => "true" )
        else
          run_command = MobyCommand::Application.new(
													 :Run,
													 target[ :name ],
													 target[ :uid ],
													 self,
													 target[ :arguments ],
													 target[ :environment ],
													 target[ :events_to_listen ],
													 target[ :signals_to_listen ]
													 )

          # execute the application control service request
          execute_command( run_command )

        end
        
        # do not remove this, unless qttas server & plugin handles the syncronization between plugin registration & first ui state request
        # first ui dump is requested too early and target/server seems not be ready...
        #sleep 0.100

        sleep sleep_time if sleep_time > 0

        #TODO: Refresh should be initiated by sut_controller
        #PKI: one refresh might not be enough as application launch takes more time sometimes
        #PKI: added artificial wait for now until this has been refactored

        expected_attributes = Hash.new

        expected_attributes[ :type ] = 'application'

        expected_attributes[ :id ] = target[ :uid ] unless target[ :uid ].nil?
        expected_attributes[ :FullName ] = target[ :name ] unless target[ :name ].nil?

        error_details = target[ :name ].nil? ? "" : "name: " << target[ :name ].to_s

        error_details << ( error_details.empty? ? "" : ", ") << "id: " << target[ :uid ].to_s if !target[ :uid ].nil?

        if( self.ui_type.downcase.include?( 'qt' ) && !expected_attributes[ :FullName ].nil? )

          if( expected_attributes[ :FullName ].include?('/') )

            app_name = expected_attributes[ :FullName ].split('/')[ expected_attributes[ :FullName ].split( '/' ).size-1 ]
            app_name.slice!( ".exe" )
            expected_attributes[ :name ] = app_name

          elsif( expected_attributes[ :FullName ].include?("\\") )

            app_name = expected_attributes[ :FullName ].split("\\")[ expected_attributes[ :FullName ].split( "\\" ).size-1 ]
            app_name.slice!( ".exe" )
            expected_attributes[:name] = app_name

          else

            app_name = expected_attributes[ :FullName ]
            app_name.slice!( ".exe" )
            expected_attributes[ :name ] = app_name

          end

          expected_attributes.delete( :FullName )

        end

        begin

          self.wait_child(
						  expected_attributes,
						  MobyUtil::Parameter[ @id ][ :application_synchronization_timeout, '5' ].to_f,
						  MobyUtil::Parameter[ @id ][ :application_synchronization_retry_interval, '0.5' ].to_f
						  )

        rescue MobyBase::SyncTimeoutError

          Kernel::raise MobyBase::VerificationError.new("The application (#{ error_details }) was not found on the sut after being launched.")

        end
        
        # verify run results
        foreground_app = self.application( expected_attributes )

        Kernel::raise MobyBase::VerificationError.new("No application type test object was found on the device after starting the application.") unless foreground_app.kind_of?( MobyBehaviour::Application )

      rescue Exception => e

        MobyUtil::Logger.instance.log "behaviour", "FAIL;Failed to launch application.;#{id.to_s};sut;{};run;" << ( target.kind_of?( Hash ) ? target.inspect : target.class.to_s )

        Kernel::raise MobyBase::BehaviourError.new("Run", "Failed to launch application")

        #MobyBase::Error.raise( :BehaviourErrorOccured, "Run", "Failed to launch application", e.message )
        #Kernel::raise behaviour_runtime_error("Run", "Failed to launch application", e.message, e.backtrace)
        #Kernel::raise e

      end

      MobyUtil::Logger.instance.log "behaviour" , "PASS;The application was launched successfully.;#{id.to_s};sut;{};run;" << target.inspect

      foreground_app

    end

    # Press_key function to pass symbol or sequence to the assosiacted SUT controllers
    # execute_cmd function.
    # === params
    # keypress:: either symbol or object of type MobyController::KeySequence
    # === returns
    # nil
    # === raises
    # ArgumentError:: if input not a symbol or not of type MobyCommand::KeySequence
    # === examples
    #  @sut.press_key(:kDown) # presses Down on SUT
    #  key_sequence = MobyCommand::KeySequence.new(:kDown).times!(3) # creates keysequence to press 3 times down on SUT
    #  @sut.press_key( key_sequence ) # executes above keysequence on device
    def press_key( symbol_or_sequence )

      begin

        if symbol_or_sequence.instance_of?( Symbol )

          sequence = MobyCommand::KeySequence.new( symbol_or_sequence )

        elsif symbol_or_sequence.instance_of? MobyCommand::KeySequence

          sequence = symbol_or_sequence

        else

          raise ArgumentError.new('Data not of type Symbol or MobyController::KeySequence.')

        end

        sequence.set_sut( self )
        execute_command( sequence )

      rescue Exception => e

        MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to press key(s).;#{id.to_s};sut;{};press_key;#{ symbol_or_sequence }"
        Kernel::raise e

      end

      MobyUtil::Logger.instance.log "behaviour" , "PASS;Successfully pressed key(s).;#{id.to_s};sut;{};press_key;#{ symbol_or_sequence }"

      nil

    end
    
    # == description
    # Wrapper function to access sut specific parameters.
    # Parameters for each sut are stored in the parameters xml file under group tag with name attribute matching the SUT id
    # ==params
    # *arguments
    #	String
    #   description: Optional argument which is the name of parameter.
    #   example: 'new_parameter'
    # 	Symbol
    # 	description: Optional argument which is the name of parameter.
    #	example: :product
    # ==return
    #String
    #	description: Value matching the parameter name given as argument
    #	example: 'testability-driver-qt-sut-plugin'
    # MobyUtil::ParameterHash
    # 	description:: Hash of values, if no arguments is specified
    # == exceptions
    # ParameterNotFoundError
    #	description: If the parameter with the given name does not exist
    # == example
    # parameter_hash = @sut.parameter	 #returns the hash of all sut parameters
    # value = @sut.parameter[:product] 	#returns the value for parameter 'product' for this particular sut
    # value = @sut.parameter['non_existing_parameter'] #raises exception that 'non_existing_parameter' was not found
    # value = sut.parameter['non_existing_parameter', 'default'] #returns default value if given parameter is not found
    # sut.parameter[:new_parameter] ='new_value'  # set the value of parameter 'product' for this particular sut
    def parameter( *arguments )

      if ( arguments.count == 0 )

        MobyUtil::ParameterUserAPI.instance[ @id ]

      else

        #$stderr.puts "%s:%s warning: deprecated method usage convention, please use sut#parameter[] instead of sut#parameter()" % ( caller.first || "%s:%s" % [ __FILE__, __LINE__ ] ).split(":")[ 0..1 ]

        MobyUtil::ParameterUserAPI.instance[ @id ][ *arguments ]

      end

    end

	# == description
	# Wrapper function to return translated string for this SUT to read the values from localisation database.
	#
	# == arguments
	# logical_name
	#  String
	#   description: Logical name (LNAME) of the item to be translated. If prefix for User Information or Operator Data are used then the appropiate retrieve methods will be called
	#   example: "txt_button_ok"
	#  Symbol
	#   description: Symbol form of the logical name (LNAME) of the item to be translated.
	#   example: :txt_button_ok
	#
	# file_name
	#  String
	#   description: Optional FNAME search argument for the translation
	#   example: "agenda"
	#   default: nil
	#
	# plurality
	#  String
	#   description: Optional PLURALITY search argument for the translation
	#   example: "a" or "singular"
	#	default: nil
	#
	# numerus
	#  String
	#   description: Optional numeral replacement of '%Ln' tags on translation strings
	#   example: "1"
	#   default: nil
	#  Integer
	#   description: Optional numeral replacement of '%Ln' tags on translation strings
	#   example: 1
	# 
	# lengthvariant
	#  String
	#   description: Optional LENGTHVAR search argument for the translation (1-9)
	#   example: "1"
	#   default: nil
	#
	# == returns
	# String
	#  description: Translation matching the logical_name
	#  example: "Ok"
	# Array
	#  description: If multiple translations have been found for the search conditions an Array with all Strings be returned
	#  example: ["Ok", "OK"]
	# 
	# == exceptions
	# LanguageNotFoundError
	#  description: In case language is not found
	#
	# LogicalNameNotFoundError
	#  description: In case no logical name is not found for current language
	#
	# SqlError
	#  description: In case there are problems with the database connectivity
	#
	def translate( logical_name, file_name = nil, plurality = nil, numerus = nil, lengthvariant = nil )
	  
	  Kernel::raise LogicalNameNotFoundError.new("Logical name is nil") if logical_name.nil?
	  
	  translation_type = "localisation"
	  
	  # Check for User Information prefix( "uif_...")
	  MobyUtil::Parameter[ :user_data_logical_string_identifier, 'uif_' ].split('|').each do |identifier|
		if logical_name.to_s.index(identifier)==0
		  translation_type="user_data"
		end
	  end
	  
	  # Check for Operator Data prefix( "operator_...")
	  MobyUtil::Parameter[ :operator_data_logical_string_identifier, 'operator_' ].split('|').each do |identifier|
		if logical_name.to_s.index(identifier)==0
		  translation_type="operator_data"
		end
	  end
	  
	  case translation_type
		
	  when "user_data"
		get_user_information( logical_name )
		
	  when "operator_data"
		get_operator_data( logical_name )
		
	  when "localisation"
		language=nil
		if ( MobyUtil::Parameter[ self.id ][:read_lang_from_app]=='true')
		  #read localeName app
		  language=self.application.attribute("localeName")
		  #determine the language from the locale
		  language=language.split('_')[0].to_s if (language!=nil && !language.empty?)
		else
		  language=MobyUtil::Parameter[ self.id ][ :language ]
		end
		Kernel::raise LanguageNotFoundError.new("Language cannot be determind to perform translation") if (language==nil || language.empty?)
		translation = MobyUtil::Localisation.translation( logical_name, language,
			MobyUtil::Parameter[ self.id ][ :localisation_server_database_tablename ], file_name,
			plurality, lengthvariant )

		if translation.kind_of? String and !numerus.nil?
		  translation.gsub!(/%(Ln|1)/){|s| numerus} 
		elsif translation.kind_of? Array and !numerus.nil?
		  translation.each do |trans|
			trans.gsub!(/%(Ln|1)/){|s| numerus}
		  end
		end
		translation
	  end
	end
	
	# == description
	# Wrapper function to retrieve user information for this SUT from the user information database.
	#
	# == arguments
	# user_data_lname
	#  String
	#   description: Logical name (LNAME) of the user information item to be retrieved.
	#   example: "uif_first_name"
	#  Symbol
	#   description: Symbol form of the logical name (LNAME) of the user information item to be retrieved.
	#   example: :uif_first_name
	#
	# == returns
	# String
	#  description: User data string
	#  example: "Ivan"
	# Array
	#  description: Array of Strings when multiple user data strings found.
	#  example: ["Ivan", "Manolo"]
	# 
	# == exceptions
	# UserDataNotFoundError
	#  description: In case the desired user data is not found
	#
	# UserDataColumnNotFoundError
	#  description: In case the desired data column name to be used for the output is not found
	#
	# SqlError
	#  description: In case there are problems with the database connectivity
	#
	def get_user_information( user_data_lname )
	  language = MobyUtil::Parameter[ self.id ][ :language ]
	  table_name = MobyUtil::Parameter[ self.id ][ :user_data_server_database_tablename ] 
	  MobyUtil::UserData.retrieve( user_data_lname, language, table_name )
	end
	
	# == description
	# Wrapper function to retrieve operator data for this SUT from the operator data database.
	#
	# == arguments
	# operator_data_lname
	#  String
	#   description: Logical name (LNAME) of the operator data item to be retrieved.
	#   example: "operator_welcome_message"
	#  Symbol
	#   description: Symbol form of the logical name (LNAME) of the operator data item to be retrieved.
	#   example: :operator_welcome_message
	#
	# == returns
	# String
	#  description: User data string
	#  example: "Welcome to Orange"
	# 
	# == exceptions
	# OperatorDataNotFoundError
	#  description: In case the desired operator data is not found
	#
	# OperatorDataColumnNotFoundError
	#  description: In case the desired data column name to be used for the output is not found
	#
	# SqlError
	#  description: In case there are problems with the database connectivity
	#
	def get_operator_data( operator_data_lname )
	  operator = MobyUtil::Parameter[ self.id ][ :operator_selected ]
	  table_name = MobyUtil::Parameter[ self.id ][ :operator_data_server_database_tablename]
	  MobyUtil::OperatorData.retrieve( operator_data_lname, operator, table_name )
	end

    # Function to update all children of current SUT
    # Iterates on all children of the SUT and calls TestObject#update on all children
    # === params
    # === returns
    # ?
    # === raises
    def update

      #@_child_objects.each{ | test_object | test_object.update( @xml_data ) } if !@childs_updated

      unless @childs_updated

        @_child_object_cache.each_value{ | test_object | 

          test_object.update( @xml_data ) 

        }


      end

      @childs_updated = true

    end

    def refresh( refresh_args = {}, creation_attributes = {})
      
      refresh_ui_dump refresh_args, creation_attributes

      # update childs only if ui state is new
      update if !@childs_updated

    end

    # == description
    # Verify always is a method for sut that allows constant verifications for the UI state.
    #
    # == arguments
    # expected
    #  Object
    #   description: Ruby object that equals to the return value of the block
    #   example: true
    #
    # message
    #  String
    #   description: Message if an error occurs
    #   example: 'Required element was not found'
    #
    # &block
    #  Proc
    #   description: Code block to execute. 
    #   example: { @sut.xml_data.empty? == false }
    #
    # &block#sut
    #  MobyBase::SUT
    #   description: 
    #     Current SUT object is passed as block parameter. If the verify block is defined outside the scope of 
    #     the current SUT (e.g. the SUT configuration file), this can be used to get a handle to the current SUT.
    #   example: -
    #
    # == returns
    # NilClass
    #  description: This method doesn't pass return value
    #  example: -
    # 
    # == exceptions
    # MobyBase::VerificationError
    #  description: If verification failed
    def verify_always( expected, message = nil, &block )

      @verify_blocks << MobyUtil::VerifyBlock.new( block,expected, message, 0, MobyUtil::KernelHelper.find_source( caller( 3 ).first.to_s ) )

    end

    def clear_verify_blocks

      @verify_blocks = []

    end

    def get_application_id
      
      orig_frozen = @frozen;

      begin

        freeze unless @frozen

        ret = self.application.id

        unfreeze unless orig_frozen
        
        return ret

      rescue

      ensure

        unfreeze unless orig_frozen

      end
      
      '-1'

    end

	private

    def fetch_references( xml )

      pids = []

      x_prev = ''
      y_prev = ''

      while true

        nodes = xml.xpath( '//object[@type = "TDriverRef"]' )

        idx = 1

        nodes.each { | element |

          pid = element.xpath('//attribute[@name = "uri"]/value/text()')[ 0 ].to_s

          if pid.nil? or pid.empty? or pid.to_i <= 0 # invalid reference

            element.remove
            next

          end

          #  Element parent not supported, so query the parent coords
          x_abs = xml.xpath( '//object[@type = "TDriverRef"]/../../attributes/attribute[@name ="x_absolute"]/value/text()' )[ idx - 1 ]
          y_abs = xml.xpath( '//object[@type = "TDriverRef"]/../../attributes/attribute[@name ="y_absolute"]/value/text()' )[ idx - 1 ]

          # window size
          winSize = xml.xpath( "//objects/object[@type = 'MainWindow']/attributes/attribute[@name ='size']/value/text()" )[ 0 ].to_s

          # ref-ref parent does not know x coordinate, use the grandparent xys
          x_prev = x_abs.to_s unless x_abs.nil?
          y_prev = y_abs.to_s unless y_abs.nil? 

          idx += 1

          if !pid.empty?

            begin

			  subdata =
				MobyUtil::XML.parse_string( 
										   execute_command( 
														   MobyCommand::Application.new(
																						:State,
																						nil,
																						pid,
																						self,
																						nil,
																						nil,
																						nil,
																						nil,
																						{
																						  'x_parent_absolute' => x_prev,
																						  'y_parent_absolute' => y_prev,
																						  'embedded' => 'true',
																						  'parent_size' => winSize
																						}
																						)
														   )[ 0 ]
										   )

			  child = subdata.root.xpath('//object')[0]

			  # Remove the attribute with the pid retrieval was not successful.
			  # (server returns the previous hit if not found)
			  if child.attribute('id' ) != pid
				
				element.remove

			  else

				# Remove the application layer
				objs = child.xpath( '/tasMessage/tasInfo/object/objects/*' )

				if !objs.nil?

				  objs.each { | el | element.add_previous_sibling( el ) }

				  element.remove

				end

			  end

            rescue RuntimeError => e

			  raise e unless e.message.include? "no longer available"

			  return xml

            end

          else

            return xml

          end

        }

        return xml if nodes.empty?

      end

    end

    def find_app( app_list, search_params )

      app_info = nil

      begin

        app_info = app_list.application( search_params )

      rescue MobyBase::TestObjectNotFoundError

        app_info = nil

      end

      app_info
    end

    # this method will be automatically invoked after module is extended to sut object
    def self.extended( target_object )

      target_object.instance_exec{

        initialize_settings

      }

    end

    def initialize_settings

      @xml_data = ""

      @x_path = '.'

      @frozen = false

      @_child_object_cache = {}

      @current_application_id = nil


      @dump_count = 0

      # default values
      @input = :key

      @refresh_tries = 5
      @refresh_interval = 0.5

      @childs_updated = false

      # id not found from parameters
      if MobyUtil::Parameter[ @id, nil ] != nil

        @input = MobyUtil::Parameter[ @id ][ :input_type, "key" ].to_sym

        @refresh_tries = MobyUtil::Parameter[ @id ][ :ui_state_refresh_tries, @refresh_tries ].to_f

        @refresh_interval = MobyUtil::Parameter[ @id ][ :refresh_interval, @refresh_interval ].to_f

      end
	  
      @last_xml_data = nil
	  
      ruby_file = MobyUtil::Parameter[ @id ][ :verify_blocks ] 

      @verify_blocks = []

      if File.exists?( ruby_file )

        load ruby_file

        SutParameters::VERIFY_BLOCKS.each { | block |

          @verify_blocks << block

        }


      end

    end

	public # deprecated

    #TODO: Update documentation
    #TODO: Is this function deprecated? (see SUT#refresh_ui_dump)
    #TODO: rethink get_ui_dump and refresh --> functions!
    # function to query for UIDump.
    # == returns
    # xmlDocument:: REXML::Document object containing valid xml fragment
    # == raises
    # someException:: If Dump does not conform to the tasMessage schema error is raised
    def get_ui_dump( refresh_args = {} )
	  
      #$stderr.puts "warning: SUT#get_ui_dump is deprecated, please use SUT#refresh_ui_dump instead."

      refresh_ui_dump refresh_args, {}

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # SUT
  
end # MobyBehaviour
