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
  # sut
  #
  module SUT

    include MobyBehaviour::Behaviour

    # == nodoc
    attr_accessor(

        :dump_count,                # number of UI dump requests done to current SUT
        :current_application_id,    # id of the current appication if set
        :input,                     # the input method used for interacting with this sut as a symbol, eg. :key or :touch.
        :refresh_tries,             # number of retries for ui dump on error case
        :refresh_timeout           # timeout between timeout retry

    )

    # == nodoc
    attr_reader(

        :xml_data,      # sut xml_data
        :x_path,        # x_path pattern for xml_data
        :ui_type,       # type of the UI used on the sut, ie. s60, qt, windows
        :ui_version,    # version of the ui used on the sut, ie 3.2.3
        :frozen,        # flag that tells if the ui dump getting is disabled
        :xml_data_crc,  # crc of the previous ui state message
        :verify_blocks  # verify blocks              

    )

    # == description
    # Connects selected SUT according to configuration in tdriver_parameters.xml.
    # == arguments
    # id
    #  Symbol
    #   description: SUT id
    #   example: :sut_qt
    # == returns
    # Boolean
    #  description: Determines if SUT is connected
    #  example: true
    def connect( id )

      @_sutController.connect( id )

    end

    # == description
    # Disconnects the current SUT
    # == returns
    # Boolean
    #  description: Determines if SUT is connected
    #  example: false
    # == examples
    #  @sut.disconnect
    def disconnect

      @_sutController.disconnect

    end

    # == description
    # Retrieves the total amount of data received in bytes
    # == returns
    # Fixnum
    #  description: Total amount of data received in bytes
    #  example: 65535
    # == examples
    #  @sut.disconnect
    def received_data
    
      @_sutController.received_bytes

    end

    # == description
    # Retrieves the total amount of data sent in bytes
    # == returns
    # Fixnum
    #  description: Total amount of data sent in bytes
    #  example: 65535
    # == examples
    #  @sut.sent_data
    def sent_data
      
      @_sutController.sent_bytes

    end

    # == description
    # Function to disable taking UI dumps from target for a moment. This method might be deprecated in future release.\n
    # \n
    # [b]NOTE:[/b] Remember to enable ui dumps again using unfreeze! 
    # == returns
    # NilClass
    #  description: -
    #  example: -
    def freeze

=begin
      if $parameters[ @id ][ :use_find_object, 'false' ] == 'true' && self.respond_to?( 'find_object' )

        warn("warning: SUT##{ __method__ } is not supported when use_find_objects optimization is enabled")

      else

        @frozen = true

      end
=end

      @frozen = true


      nil

    end

    # == description
    # Function to enable taking ui dumps from target. This method might be deprecated in future release.\n
    # \n
    # == returns
    # NilClass
    #  description: -
    #  example: -
    def unfreeze

=begin
      if $parameters[ @id ][ :use_find_object, 'false' ] == 'true' && self.respond_to?( 'find_object' )

        warn("warning: SUT##{ __method__ } is not supported when use_find_objects optimization is enabled")

      else
      
        @frozen = false

      end
=end

      @frozen = false
  
      nil

    end

    # == nodoc  
    # == description
    # Force to use user defined ui state (e.g. for debugging purposes). Freezes the SUT xml_data, until unfreezed or set to nil. 
    #
    # == arguments
    # xml
    #  String
    #   description: Freeze SUT XML data with given XML string
    #   example: "<tasMessage>.....</tasMessage>"
    #  MobyUtil::XML::Element
    #   description: Freeze SUT XML data with given XML element
    #   example: -
    #  NilClass
    #   description: Unfreeze SUT XML data
    #   example: nil
    #
    # == returns
    # NilClass
    #  description: This method doesn't return anything
    #  example: -
    #
    # == exception
    # TypeError
    #  description: Wrong argument type %s for XML (expected MobyUtil::XML::Element, String or NilClass)
    def xml_data=( xml )

      xml.check_type( [ MobyUtil::XML::Element, String, NilClass ], "Wrong argument type $1 for XML (expected $2)" )

      if xml.kind_of?( MobyUtil::XML::Element )

        @xml_data = xml
        @frozen = true
        @forced_xml = true

      elsif xml.kind_of?( String )

        @xml_data = MobyUtil::XML.parse_string( xml ).root
        @frozen = true
        @forced_xml = true

      elsif xml.kind_of?( NilClass )

        @xml_data = nil
        @frozen = false
        @forced_xml = false

      end

      nil

    end

    # TODO: merge TestObject#child and SUT#child 
    # == description
    # Creates a child test object from this SUT. SUT object will be associated as child test objects parent.\n
    #
    # [b]NOTE:[/b] Subsequent calls to TestObject#child( rule ) always returns reference to same Testobject:\n
    # [code]a = sut.child( :type => 'Button', :text => '1' )
    # b = sut.child( :type => 'Button', :text => '1' )
    # a.eql?( b ) # => true[/code]
    #
    # == arguments
    # attributes
    #  Hash
    #   description: Hash object holding information for identifying which child to create
    #   example: { :type => "application" }
    #
    # == returns
    # TestObject
    #  description: New child test object or reference to existing child
    #  example: -
    def child( attributes )

      ###############################################################################################################
      #
      #  NOTICE: Please do not add anything unnessecery to this method, it might cause a major performance impact
      #
            
      # verify attributes argument format
      attributes.check_type( Hash, "Wrong argument type $1 for attributes (expected $2)" )
            
      # store original hash
      creation_hash = attributes.clone

      identification_directives = creation_hash.strip_dynamic_attributes!

      # raise exception if wrong value type given for ;__logging 
      identification_directives[ :__logging ].check_type( 
      
        [ TrueClass, FalseClass ], 
        
        "Wrong value type $1 for :__logging test object creation directive (expected $2)"
        
      ) if identification_directives.has_key?( :__logging )

      # disable logging if requested, remove pair from creation_hash
      $logger.push_enabled( identification_directives[ :__logging ] || TDriver.logger.enabled )

      begin

        # TODO: refactor me
        child_test_object = @test_object_factory.get_test_objects(

          # current object as parent, can be either TestObject or SUT
          :parent => self,
  
          # test object identification hash
          :object_attributes_hash => creation_hash,
          
          :identification_directives => identification_directives

        )

      rescue MobyBase::MultipleTestObjectsIdentifiedError => exception

        TDriver.logger.behaviour "FAIL;Multiple child objects matched criteria.;#{ id };sut;{};child;#{ attributes.inspect }"

        Kernel::raise exception

      rescue MobyBase::TestObjectNotFoundError => exception

        TDriver.logger.behaviour "FAIL;The child object could not be found.;#{ id };sut;{};child;#{ attributes.inspect }"

        Kernel::raise exception

      rescue Exception => exception

        TDriver.logger.behaviour "FAIL;Failed when trying to find child object.;#{ id };sut;{};child;#{ attributes.inspect }"

        Kernel::raise exception

      ensure

        # restore original logger state
        $logger.pop_enabled

      end

      # return child test object
      child_test_object

    end

    # == description
    # Returns a StateObject containing the current state of this test object as XML.
    # The state object is static and thus is not refreshed or synchronized etc.
    # == returns
    # StateObject
    #  description: State of this test object
    #  example: -
    # == exceptions
    # RuntimeError
    #  description: If the XML source for the object is not in initialized
    def state

      # refresh if xml data is empty
      self.refresh if @xml_data.empty?

      Kernel::raise RuntimeError, "Can not create state object of SUT with id #{ @id.inspect }, no XML content or SUT not initialized properly." if @xml_data.empty?

      MobyBase::StateObject.new( TDriver::TestObjectAdapter.state_object_xml( @xml_data, @id ), self )

    end

    # == description
    # Returns the current foreground application or one which matches with given attributes rules.
    #
    # == arguments
    # attributes
    #  Hash
    #   description: Hash defining required expected attributes of the application
    #   example: { :name => 'testapp' }
    #
    # == returns
    # MobyBase::TestObject
    #  description: Current foreground application or one that meets hash rules
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type %s for attributes (expected Hash)
    #
    def application( attributes = {} )

      begin
      
        attributes.check_type( Hash, "Wrong argument type $1 for attributes (expected $2)" )

        attributes[ :type ] = 'application'

        attributes[ :__parent_application ] = nil

        @current_application_id = nil if attributes[ :id ].nil?

        # create test object and return it as result 
        test_object = child( attributes )

        # store parent application to test object
        test_object.instance_variable_set( :@parent_application, test_object )

        test_object
        
      rescue
      
        TDriver.logger.behaviour(
          "FAIL;Failed to find application.;#{ id.to_s };sut;{};application;#{ attributes.kind_of?( Hash ) ? attributes.inspect : attributes.class.to_s }"
        )

        # raise same exception
        Kernel::raise $!

      ensure
      
        TDriver.logger.behaviour "PASS;Application found.;#{ id.to_s };sut;{};application;#{ attributes.inspect }" if $!.nil?
      
      end

    end

    # == description
    # Screen capture function to take snapshot of SUTs current display view
    #
    # == arguments
    # arguments
    #  Hash
    #   description: 
    #    Options to be used for screen capture. See [link="#capture_options_table"]Options table[/link] for valid keys
    #   example: ( :filename => "output.png" )
    #
    # == tables
    # capture_options_table
    #  title: Options table
    #  |Key|Type|Description|Example|Required|
    #  |:filename|String|Store output binary to this file. Absolute or relative path supported.|:filename => "screen_shots/output.png"|Yes|
    #
    # == returns
    # NilClass
    #   description: -
    #   example: -    
    #
    # == exceptions
    # TypeError
    #   description: Wrong argument type %s (expected Hash)
    #
    # ArgumentError
    #   description: Output filename (:filename) not defined in argument hash
    #
    # ArgumentError
    #  description: Wrong argument type %s for output filename (expected String)
    #
    # ArgumentError 
    #   description: Output filename must not be empty string
    # 
    def capture_screen( arguments )

      begin

        # raise exception with default message if wrong argument type given
        arguments.check_type( Hash, "Wrong argument type $1 (expected $2)" )

        # legacy support: support also :Filename
        arguments[ :filename ] = arguments.delete( :Filename ) if arguments.has_key?( :Filename )

        # raise exception with default message if hash doesn't contain required key
        arguments.require_key( :filename, "Output filename ($1) not defined in argument hash" )

        # verify that filename is type of String
        arguments[ :filename ].check_type( String, "Wrong argument type $1 for output filename (expected $2)" )

        # verify that filename is not empty string
        arguments[ :filename ].not_empty( "Output filename must not be empty string" )

        # create screen capture command object
        command = MobyCommand::ScreenCapture.new()

        command.redraw = arguments[ :Redraw ] if arguments[ :Redraw ]

        # execute command and write binary to file
        File.open( File.expand_path( arguments[ :filename ] ), 'wb:binary' ){ | file | 

          file << execute_command( command ) 

        }

      rescue 

        TDriver.logger.behaviour "FAIL;Failed to capture screen.;#{ id.to_s };sut;{};capture_screen;#{ arguments.kind_of?( Hash ) ? arguments.inspect : arguments.class.to_s }"

        Kernel::raise $!

      end

      TDriver.logger.behaviour "PASS;Screen was captured successfully.;#{ id.to_s };sut;{};capture_screen;#{ arguments.inspect }"

      nil

    end

    # == description
    # Instructs the SUT to start the specified application if it is not currenly being executed
    # The application will also be brought to the foregound.
    #
    # == arguments
    # target
    #  Hash
    #   description: used to indetify the application to be executed. All symbols defined in the hash must match with the launched application. See application [link="#run_hash_arguments"]run argument hash keys[/link] table.
    #   example: { :name => 'calculator' }
    #
    # == tables
    # run_hash_arguments
    #  title: Run argument hash keys
    #  description: The following symbols can be defined in the hash, at least one them must be defined.
    #  |Key|Type|Description|Example|
    #  |:uid|String or Integer|Unique ID of the application|{ :uid => 268458181 }|
    #  |:name|String|Executable name of the application|{ :name => 'calculator' }|
    #  |:arguments|String|Comma separated list of arguments passed to application when starting|{ :arguments => '--nogui,-v' }|
    #
    # == returns
    # TestObject
    #  description: Test object of the started application
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type %s for run method (expected Hash)
    #  
    # ArgumentError
    #  description: Required key :uid or :name not found from argument hash
    #
    # VerificationError
    #  description: If no application test object can be found after starting the application, or the found object does not match the launched application
    #
    def run( target )

      begin

        # set the refresh interval to zero while the application is launched
        #orig_interval = $parameters[ @id ][ :refresh_interval ]
        #$parameters[ @id ][ :refresh_interval ] = '0'

        # raise exception if argument type other than hash
        target.check_type( Hash, "Wrong argument type $1 for run method (expected $2)" )

        # default value for missing keys
        target.default = nil

        # raise exception if :uid or :name not found from hash
        target.require_key( [ :uid, :name ], "Required key :uid or :name not found from argument hash" )

        sleep_time = target[ :sleep_after_launch ].to_i

        Kernel::raise ArgumentError, "Sleep time need to be >= 0" unless sleep_time >= 0

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

              TDriver.logger.warning "Could not bring app to foreground"

            end

            return app

          end

        end

        if ( target[ :start_command ] != nil )

          Kernel::raise MobyBase::BehaviourError.new("Run", "Failed to load execute_shell_method") unless self.respond_to?("execute_shell_command")

          execute_shell_command( target[ :start_command ], :detached => "true" )

        else

          # execute the application control service request
          execute_command(

            MobyCommand::Application.new(
              :Run,
              target[ :name ],
              target[ :uid ],
              self,
              target[ :arguments ],
              target[ :environment ],
              target[ :events_to_listen ],
              target[ :signals_to_listen ]
            )

          )

        end
        
        # do not remove this, unless qttas server & plugin handles the syncronization between plugin registration & first ui state request
        # first ui dump is requested too early and target/server seems not be ready...
        #sleep 0.100

        sleep sleep_time if sleep_time > 0

        expected_attributes = { :type => 'application' }

        expected_attributes[ :id ] = target[ :uid ] unless target[ :uid ].nil?

        expected_attributes[ :FullName ] = target[ :name ] unless target[ :name ].nil?

        error_details = target[ :name ].nil? ? "" : "name: " << target[ :name ].to_s
        error_details << ( error_details.empty? ? "" : ", ") << "id: " << target[ :uid ].to_s if !target[ :uid ].nil?

        if( !expected_attributes[ :FullName ].nil? )

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

          # verify that application is launched and application test object is found from xml
          self.wait_child(

            # attributes to identify application object
            expected_attributes,

            # timeout to for application synchronization
            $parameters[ @id ][ :application_synchronization_timeout, '5' ].to_f,

            # wait retry interval and try again if application was not found
            $parameters[ @id ][ :application_synchronization_retry_interval, '0.5' ].to_f

          )

          # retrieve application object element from sut.xml_data
          matches, unused_rule = TDriver::TestObjectAdapter.get_objects( xml_data, expected_attributes, true )

          # raise exception if application element was not found; this shouldn't ever happen?
          #raise MobyBase::TestObjectNotFoundError if matches.count == 0

          # create application test object
          foreground_app = @test_object_factory.make_test_object( 
        
            :parent => self,
            
            :parent_application => nil,
            
            :object_attributes_hash => expected_attributes,
            
            :xml_object => matches.first
        
          )

          # store application reference to test application; this will be passed to it's child test object(s)
          foreground_app.instance_variable_set( :@parent_application, foreground_app )

          # application was not found; this scenario shouldn't ever happen?
          #raise MobyBase::TestObjectNotFoundError unless foreground_app.kind_of?( MobyBehaviour::Application )

        rescue MobyBase::TestObjectNotFoundError

          Kernel::raise MobyBase::VerificationError, "No application type test object was found on the device after starting the application."

        rescue MobyBase::SyncTimeoutError

          Kernel::raise MobyBase::VerificationError, "The application (#{ error_details }) was not found on the sut after being launched."

        end

      # raise behaviour error if any exception is raised
      rescue # Exception => e

        TDriver.logger.behaviour "FAIL;Failed to launch application.;#{ id.to_s };sut;{};run;#{ target.kind_of?( Hash ) ? target.inspect : target.class.to_s }"

        Kernel::raise MobyBase::BehaviourError.new("Run", "Failed to launch application")

      end

      TDriver.logger.behaviour "PASS;The application was launched successfully.;#{ id.to_s };sut;{};run;#{ target.inspect }"

      foreground_app

    end

    # == description
    # Performs a key press or key press sequence to SUT. Key press sequence can contain more complex operations such as holding multiple keys down at the same. Key map file is provided by SUT plugin and is configured in TDriver parameters and/or SUT template XML file (tdriver_parameters.xml).\n
    # \n
    # [b]Note for Qt users:[/b]\n
    # If the focus is not currently on target object you need to use the it's own press_key method or tap it before sending any key press events.
    #
    # == tables
    # press_key_sequences
    #  title: Keypress sequence types
    #  description: Describes different types of keypresses. All types are symbols. The amount of time each key are held and time between presses can be specified in tdriver_parameters.xml: short_press are for "normal" keypresses, while long_press are for keypresses of type :LongPress
    #  |Type|Description|Example|
    #  |:KeyDown|Holds key down on SUT until it is released|MobyCommand::KeySequence.new(:kShift, :KeyDown)|
    #  |:KeyUp|Releases a key that was held down on SUT|MobyCommand::KeySequence.new(:kShift, :KeyUp)|
    #  |:LongPress|Holds a key as long_press_timeout specifies in tdriver_parameters.xml. Please note also long_press_interval (Only for S60)|MobyCommand::KeySequence.new( :kApp, :LongPress )|
    #
    # == tables
    # press_key_sequences_methods
    #  title: Keypress sequence methods
    #  description: Specifies possible altering methods for keysequnces. All keysequences are created with MobyCommand::KeySequence.new
    #  |Type|Description|Example|
    #  |:KeyDown|Holds key down on SUT until it is released|MobyCommand::KeySequence.new(:kShift, :KeyDown)|
    #  |:KeyUp|Releases a key that was held down on SUT|MobyCommand::KeySequence.new(:kShift, :KeyUp)|
    #  |:LongPress|Holds a key as long_press_timeout specifies in tdriver_parameters.xml. Please note also long_press_interval (Only for S60)|MobyCommand::KeySequence.new( :kApp, :LongPress )|
    #
    # == arguments
    # value
    #  Symbol
    #   description: one of the key symbols defined in /tdriver/keymaps/
    #   example: @sut.press_key(:kDown)
    #  MobyCommand::KeySequence
    #   description: a KeySequence object of key symbols
    #   example: @sut.press_key( MobyCommand::KeySequence.new(:kDown).times!(3).append!(:kLeft) )
    # 
    # == returns
    # NilClass
    #  description: -
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type $1 for press_key (expected $2)
    #
    def press_key( value )

      begin

        value.check_type( [ Symbol, MobyCommand::KeySequence ], "Wrong argument type $1 for press_key (expected $2)" )

        sequence = value.kind_of?( Symbol ) ? MobyCommand::KeySequence.new( value ) : value

        sequence.set_sut( self )

        execute_command( sequence )

      rescue 

        TDriver.logger.behaviour "FAIL;Failed to press key(s).;#{id.to_s};sut;{};press_key;#{ value }"

        Kernel::raise $!

      end

      TDriver.logger.behaviour "PASS;Successfully pressed key(s).;#{ id.to_s };sut;{};press_key;#{ value }"

      nil

    end
    
    # == description
    # Wrapper function to access sut specific parameters.
    # Parameters for each sut are stored in the parameters xml file under group tag with name attribute matching the SUT id
    #
    # == arguments
    # *arguments
    #   String
    #   description: Optional argument which is the name of parameter.
    #   example: 'new_parameter'
    #  Symbol
    #   description: Optional argument which is the name of parameter.
    #    example: :product
    #
    # == returns
    # String
    #   description: Value matching the parameter name given as argument
    #   example: 'testability-driver-qt-sut-plugin'
    #
    # MobyUtil::ParameterHash
    #   description: Hash of values, if no arguments is specified
    #   example: { :value => '1', :inner_hash => { :another_value => 100 } }
    #
    # == exceptions
    # ParameterNotFoundError
    #   description: If the parameter with the given name does not exist
    #
    # == example
    # parameter_hash = @sut.parameter   #returns the hash of all sut parameters
    # value = @sut.parameter[:product]   #returns the value for parameter 'product' for this particular sut
    # value = @sut.parameter['non_existing_parameter'] #raises exception that 'non_existing_parameter' was not found
    # value = sut.parameter['non_existing_parameter', 'default'] #returns default value if given parameter is not found
    # sut.parameter[:new_parameter] ='new_value'  # set the value of parameter 'product' for this particular sut
    def parameter( *arguments )

      if ( arguments.count == 0 )

        MobyUtil::ParameterUserAPI[ @id ]

      else

        #$stderr.puts "%s:%s warning: deprecated method usage convention, please use sut#parameter[] instead of sut#parameter()" % ( caller.first || "%s:%s" % [ __FILE__, __LINE__ ] ).split(":")[ 0..1 ]

        MobyUtil::ParameterUserAPI[ @id ][ *arguments ]

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
  #  default: nil
  #
  # numerus
  #  String
  #   description: Optional numeral replacement of an '%Ln | %1' tag on the translated string
  #   example: "1"
  #   default: nil
  #  Integer
  #   description: Optional numeral replacement of an '%Ln | %1' tag on the translated string
  #   example: 1
  #  Array
  #   description: Optional numeral replacements for multiple '%L1 | %1, %L2 | %2, ...' tags on the translated string
  #   example: [ 3, 2]
  # 
  # lengthvariant
  #  String
  #   description: Optional argument to specify a length variant with its priority number (1-9). Translations with no length variants are considered a variant of priority "1". The default 'nil' value will retrieve all variants available.
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

    Kernel::raise LogicalNameNotFoundError, "Logical name is nil" if logical_name.nil?

    translation_type = "localisation"
    
    # Check for User Information prefix( "uif_...")
    $parameters[ :user_data_logical_string_identifier, 'uif_' ].split('|').each do |identifier|

      if logical_name.to_s.index(identifier)==0

        translation_type="user_data"

      end

    end
    
    # Check for Operator Data prefix( "operator_...")
    $parameters[ :operator_data_logical_string_identifier, 'operator_' ].split('|').each do |identifier|

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
        
        if ( $parameters[ self.id ][:read_lang_from_app]=='true')

          #read localeName app
          language=self.application.attribute("localeName")

          #determine the language from the locale
          language=language.split('_')[0].to_s if (language!=nil && !language.empty?)

        else

          language=$parameters[ self.id ][ :language ]

        end
        
        Kernel::raise LanguageNotFoundError, "Language cannot be determind to perform translation" if ( language.nil? || language.empty? )

        translation = MobyUtil::Localisation.translation( 
          logical_name, 
          language,
          $parameters[ self.id ][ :localisation_server_database_tablename ], 
          file_name, 
          plurality, 
          lengthvariant 
        )        

        if translation.kind_of? String and !numerus.nil?

          if numerus.kind_of? Array

            translation.gsub!(/%[L]?(\d)/){|s| numerus[($1.to_i) -1] }

          elsif numerus.kind_of? String or numerus.kind_of? Integer

            translation.gsub!(/%(Ln|1)/){|s| numerus.to_s} 

          end

        elsif translation.kind_of? Array and !numerus.nil?

          translation.each do |trans|

            if numerus.kind_of? Array

              trans.gsub!(/%[L]?(\d)/){|s| numerus[($1.to_i) -1] }

            elsif numerus.kind_of? String or numerus.kind_of? Integer

              trans.gsub!(/%(Ln|1)/){|s| numerus.to_s} 

            end

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

    MobyUtil::UserData.retrieve( 
      
      user_data_lname, 
      
      # language
      $parameters[ self.id ][ :language ],
        
      # table name
      $parameters[ self.id ][ :user_data_server_database_tablename ] 
      
    )

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

    MobyUtil::OperatorData.retrieve( 

      operator_data_lname, 

      # operator 
      $parameters[ self.id ][ :operator_selected ],

      # table name 
      $parameters[ self.id ][ :operator_data_server_database_tablename ]
      
    )

  end

    # == nodoc
    # Function to update all children of current SUT
    # Iterates on all children of the SUT and calls TestObject#update on all children
    # === params
    # === returns
    # ?
    # === raises
    def update

      #@_child_objects.each{ | test_object | test_object.update( @xml_data ) } if !@childs_updated

      unless @childs_updated

        @child_object_cache.each_object{ | test_object | 

          test_object.send( :update, @xml_data )

          #test_object.update( @xml_data ) 

        }

      end

      @childs_updated = true

    end
    
    # == nodoc
    def refresh( refresh_args = {}, creation_attributes = {} )
            
      refresh_ui_dump( refresh_args, creation_attributes )

      # update childs only if ui state is new
      update_childs

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

      nil

    end

    # == description
    # Clears all verification blocks added to the sut through verify_always() method and
    # verify_blocks configuration parameter in the tdriver parameters file
    #
    # == returns
    # Array
    #  description: Empty array
    #  example: []
    def clear_verify_blocks

      @verify_blocks = []

    end

    # == nodoc
    def get_application_id
     
      # retrieve application object from sut.xml_data
      matches, unused_rule = TDriver::TestObjectAdapter.get_objects( xml_data, { :type => 'application' }, true )

      # retrieve id attribute if application test object found      
      if matches.count > 0

        # return id attribute value
        TDriver::TestObjectAdapter.test_object_element_attribute( matches.first, 'id' )
      
      else
      
        # application not found
        '-1'
      
      end

    end

  private

    # TODO: document me
    def update_childs
        
      # update childs only if ui state is new
      update if !@childs_updated
    
    end
  
    # == nodoc
    # Function asks for fresh xml ui data from the device and stores the result
    # == returns
    # MobyUtil::XML::Element:: xml document containing valid xml fragment describing the current state of the device
    def refresh_ui_dump( refresh_args = {}, creation_attributes = [] )

      current_time = Time.now

      if !@frozen && ( @_previous_refresh.nil? || ( current_time - @_previous_refresh ).to_f >= @refresh_interval )

        use_find_objects = $parameters[ @id ][ :use_find_object, 'false' ] == 'true' and self.respond_to?( 'find_object' )
        
        refresh_arguments = refresh_args.clone

        MobyUtil::Retryable.while(
          :tries => @refresh_tries,
          :interval => @refresh_interval,
          :unless => [ MobyBase::ControllerNotFoundError, MobyBase::CommandNotFoundError, MobyBase::ApplicationNotAvailableError ] 
        ) {

          #use find_object if set on and the method exists
          if use_find_objects

            new_xml_data, crc = find_object( refresh_arguments, creation_attributes )

          else

            app_command = MobyCommand::Application.new( 
              :State, 
              refresh_args[ :FullName ] || refresh_args[ :name ],
              refresh_args[ :id ], 
              self 
            ) 

            # store in case needed
            app_command.refresh_args( refresh_args )

            new_xml_data, crc = execute_command( app_command )

          end  

          @dump_count += 1

          @childs_updated = false
          
          @xml_data = MobyUtil::XML.parse_string( new_xml_data ).root

          @_previous_refresh = Time.now

          # remove timestamp from the beginning of tasMessage, parse if not same as previous ui state
          #if ( xml_data_no_timestamp = new_xml_data.split( ">", 2 ).last ) != @last_xml_data          
          # @xml_data = MobyUtil::XML.parse_string( new_xml_data ).root
          # @last_xml_data = xml_data_no_timestamp
          #end

          #if ( @xml_data_crc == 0 || crc != @xml_data_crc || crc.nil? )          
          # @xml_data, @xml_data_crc, @childs_updated = MobyUtil::XML.parse_string( new_xml_data ).root, crc, false
          #end

        } 

      end

      fetch_references( @xml_data )
      
    end

    # TODO: document me
    def fetch_references( xml )

      pids = []

      x_prev = ''
      y_prev = ''

      while true

        nodes = xml.xpath( '//object[@type = "TDriverRef"]' )

        idx = 1

        nodes.each { | element |

          pid = element.at_xpath('//attribute[@name = "uri"]/value/text()').content #[ 0 ].to_s

          if pid.nil? or pid.empty? or pid.to_i <= 0 # invalid reference

            element.remove
            next

          end

          #  Element parent not supported, so query the parent coords
          x_abs = xml.xpath( '//object[@type = "TDriverRef"]/../../attributes/attribute[@name ="x_absolute"]/value/text()' )[ idx - 1 ]
          y_abs = xml.xpath( '//object[@type = "TDriverRef"]/../../attributes/attribute[@name ="y_absolute"]/value/text()' )[ idx - 1 ]

          # window size
          winSize = xml.at_xpath( "//objects/object[@type = 'MainWindow']/attributes/attribute[@name ='size']/value/text()" ).content #[ 0 ].to_s

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

            rescue MobyBase::ApplicationNotAvailableError => e

              # Ignore the application not available error
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

      @child_object_cache = TDriver::TestObjectCache.new

      @current_application_id = nil

      @dump_count = 0

      # default values
      @input = :key

      @refresh_tries = 5
      @refresh_interval = 0.5

      @childs_updated = false

      # id not found from parameters
      if $parameters[ @id, nil ] != nil

        @input = $parameters[ @id ][ :input_type, "key" ].to_sym

        @refresh_tries = $parameters[ @id ][ :ui_state_refresh_tries, @refresh_tries ].to_f

        @refresh_interval = $parameters[ @id ][ :refresh_interval, @refresh_interval ].to_f

      end
    
      @last_xml_data = nil
    
      ruby_file = $parameters[ @id ][ :verify_blocks ] 

      @verify_blocks = []

      if File.exists?( ruby_file )

        load ruby_file

        SutParameters::VERIFY_BLOCKS.each { | block |

          @verify_blocks << block

        }


      end

    end

  public # deprecated

    # == nodoc
    # function to get TestObject
    # TODO: Still under construction. Should be able to create single descendant of the SUT
    # Then is Should create path (parent-child-child-child...) until reaching the particular TestObject
    # TODO: Document me when I'm ready
    def get_object( object_id )

      warn("deprecated: use SUT#child instead of SUT#get_object in order to retrieve child test objects")

      child( object_id )

    end
    
    # == nodoc
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
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # SUT
  
end # MobyBehaviour
