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
      :refresh_timeout            # timeout between timeout retry

    )

    # == nodoc
    attr_reader(

      :xml_data,          # sut xml_data
      :x_path,            # x_path pattern for xml_data
      :ui_type,           # type of the UI used on the sut, ie. s60, qt, windows
      :ui_version,        # version of the ui used on the sut, ie 3.2.3
      :frozen,            # flag that tells if the ui dump getting is disabled
      :xml_data_checksum, # checksum of the previous ui state message
      :verify_blocks,     # verify blocks
      :sut

    )

  private

    # this method will be automatically invoked after module is extended to sut object
    def self.extended( target_object )

      target_object.instance_exec{

        initialize_settings

      }

    end

    # TODO: document me
    def initialize_settings

      # default values
      @x_path = '.'
      @xml_data = ""
      @dump_count = 0

      # determines that should child test objects be updated
      @update_childs = true
      
      @last_xml_data = nil
      @frozen = false

      @use_find_objects = nil

      # initialize cache for sut children
      @child_object_cache = TDriver::TestObjectCache.new

      @current_application_id = nil

      # create empty hash for sut parameters if sut id not found from parameters
      $parameters[ @id ] = {} unless $parameters.has_key?( @id )

      @input            = sut_parameters[ :input_type,             'key' ].to_sym
      @refresh_tries    = sut_parameters[ :ui_state_refresh_tries, '5'   ].to_f
      @refresh_interval = sut_parameters[ :refresh_interval,       '0.5' ].to_f

      # load verify blocks from defined sut configuration file 
      @verify_blocks    = load_verify_blocks( sut_parameters[ :verify_blocks, nil ] )
      
    end
    
  public

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

      @sut_controller.connect( id )

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

      @sut_controller.disconnect

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

      @sut_controller.received_bytes

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

      @sut_controller.sent_bytes

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
      if sut_parameters[ :use_find_object, 'false' ] == 'true' && respond_to?( 'find_object' )

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
      if sut_parameters[ :use_find_object, 'false' ] == 'true' && respond_to?( 'find_object' )

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
    #  description: Wrong argument type <class> for XML (expected MobyUtil::XML::Element, String or NilClass)
    def xml_data=( xml )

      xml.check_type( [ MobyUtil::XML::Element, String, NilClass ], "Wrong argument type $1 for XML (expected $2)" )

      if xml.kind_of?( MobyUtil::XML::Element )

        @test_object_adapter = @test_object_adapter.identify_test_object_adapter_from_data( xml )

        @xml_data = xml
        @frozen = true
        @forced_xml = true

      elsif xml.kind_of?( String )

        @test_object_adapter = @test_object_adapter.identify_test_object_adapter_from_data( xml )

        @xml_data = MobyUtil::XML.parse_string( xml )
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
      $logger.push_enabled( identification_directives[ :__logging ] || $logger.enabled )

      begin

        # TODO: refactor me
        child_test_object = @test_object_factory.get_test_objects(

          # current object as parent, can be either TestObject or SUT
          :parent => self,

          # test object identification hash
          :object_attributes_hash => creation_hash,

          :identification_directives => identification_directives

        )

      rescue MobyBase::MultipleTestObjectsIdentifiedError

        $logger.behaviour "FAIL;Multiple child objects matched criteria.;#{ id };sut;{};child;#{ attributes.inspect }"

        raise

      rescue MobyBase::TestObjectNotFoundError

        $logger.behaviour "FAIL;The child object could not be found.;#{ id };sut;{};child;#{ attributes.inspect }"

        raise

      rescue Exception

        $logger.behaviour "FAIL;Failed when trying to find child object.;#{ id };sut;{};child;#{ attributes.inspect }"

        raise

      ensure

        # restore original logger state
        $logger.pop_enabled

      end

      # return child test object
      child_test_object

    end


    # == description
    # Method for executing sut specific setup method
    # https://projects.forum.nokia.com/Testabilitydriver/wiki/FeatureSutSetupTeardown
    # == returns
    # Result
    #  description: -
    #  example: -
    # == exceptions
    # BehaviourError
    #  description: If the implementation is missing for the method
    def setup

      if sut_parameters[ :sut_setup, nil ] || sut_parameters[ :setup, nil ]

        if sut_parameters[ :sut_setup, nil ]

          require MobyUtil::FileHelper.expand_path( sut_parameters[ :sut_setup ] )

          $logger.behaviour "PASS;sut.setup method found"

          setup

          $logger.behaviour "PASS;sut.setup executed"

        end

        if sut_parameters[ :setup, nil ]

          $logger.behaviour "PASS;sut.setup parameters found"

          methods = sut_parameters[ :setup ]

          methods.each do | method |

            m = method[0].to_s

            args = method[1]

            if args.to_s == ""

              eval("self.#{m}")

            else

              eval("self.#{m}(:#{args.to_sym})")

            end

          end

          $logger.behaviour "PASS;sut.setup parameter methods executed"

        end

      else

        $logger.behaviour "FAIL;No methods or parameters found for sut.setup"
        raise MobyBase::BehaviourError.new("Setup", "Failed to load sut.setup method check the :sut_setup parameter")
        
      end

    end

    # == description
    # Method for executing sut specific teardown method
    # https://projects.forum.nokia.com/Testabilitydriver/wiki/FeatureSutSetupTeardown
    # == returns
    # Result
    #  description: -
    #  example: -
    # == exceptions
    # BehaviourError
    #  description: If the implementation is missing for the method
    def teardown

      if sut_parameters[ :sut_teardown, nil ] || sut_parameters[ :teardown, nil ]

        if sut_parameters[ :sut_teardown, nil ]

          require MobyUtil::FileHelper.expand_path(sut_parameters[ :sut_teardown ])

          $logger.behaviour "PASS;sut.teardown method found"

          teardown

          $logger.behaviour "PASS;sut.teardown executed"

        end

        if sut_parameters[ :teardown, nil ]

          $logger.behaviour "PASS;sut.teardown parameters found"

          methods = sut_parameters[ :teardown ]

          methods.each do | method |

            m = method[0].to_s

            args = method[1]

            if args.to_s == ""

              eval("self.#{m}")

            else

              eval("self.#{m}(:#{args.to_sym})")

            end

          end

          $logger.behaviour "PASS;sut.teardown parameter methods executed"

        end

      else

        $logger.behaviour "FAIL;No method or parameters found for sut.teardown"

        raise MobyBase::BehaviourError.new("Teardown", "Failed to load sut.teardown method check the :sut_teardown parameter")
        
      end

    end

    # == description
    # Creates a state object of current test object or given XML as argument. The state object is static and thus is not refreshed or synchronized.
    #
    # == arguments
    # source_data
    #  String
    #   description: Object state as XML string
    #   example: -
    #  MobyBase::XML::Element
    #   description: Object state as XML element
    #   example: -
    #
    # parent_object
    #  MobyBase::TestObject
    #   description: Parent object
    #   example: -
    #  MobyBase::SUT
    #   description: Parent object
    #   example: -
    #  NilClass
    #   description: No parent object defined
    #   example: nil
    #
    # == returns
    # MobyBase::StateObject
    #  description: State of this SUT, test object or given XML
    #  example: -
    #
    # == exceptions
    # ArgumentError
    #  description: Wrong argmument type given
    # RuntimeError
    #  description: If the XML source for the object is not in initialized
    def state_object( source_data = nil, parent_object = nil )

      if source_data.nil?

        # refresh if xml data is empty
        refresh if @xml_data.empty?

        raise RuntimeError, "Can not create state object of SUT with id #{ @id.inspect }, no XML content or SUT not initialized properly." if @xml_data.empty?

        source_data = @test_object_adapter.state_object_xml( @xml_data, @id )

        parent_object = self

      end

      # verify that type of xml_source argument is correct
      source_data.check_type [ String, MobyUtil::XML::Element ], 'wrong argument type $1 for state object source data (expected $2)'

      parent_object.check_type [ MobyBase::SUT, MobyBase::TestObject, MobyBase::StateObject, NilClass ], 'wrong argument type $1 for parent object (expected $2)'

      MobyBase::StateObject.new( 

        :source_data => source_data, 
        :parent => parent_object,
        :test_object_adapter => @test_object_adapter

      )

    end

    # == description
    # Returns the current foreground application or one which matches with given attributes rules.
    #
    # == arguments
    # target
    #  Hash
    #   description: Hash defining required expected attributes of the application
    #   example: { :name => "testapp" }
    #  String
    #   description: Name of application
    #   example: "testapp"
    #
    # == returns
    # MobyBase::TestObject
    #  description: Current foreground application or one that meets hash rules
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type <class> for attributes (expected Hash)
    #
    def application( target = {} )

      begin

        # raise exception if argument type other than hash
        target.check_type( [ String, Hash ], "Wrong argument type $1 for application identification rules (expected $2)" )

        # if target application is given as string, interpret it as application name
        target = { :name => target.to_s } if target.kind_of?( String )

        target[ :type ] = 'application'

        target[ :__parent_application ] = nil

        @current_application_id = nil if target[ :id ].nil?

        # create test object and return it as result
        test_object = child( target )

        # store parent application to test object
        test_object.instance_variable_set( :@parent_application, test_object )

        test_object

      rescue

        $logger.behaviour(
          "FAIL;Failed to find application.;#{ id.to_s };sut;{};application;#{ target.kind_of?( Hash ) ? target.inspect : target.class.to_s }"
        )

        # raise same exception
        raise

      ensure

        $logger.behaviour "PASS;Application found.;#{ id.to_s };sut;{};application;#{ target.inspect }" if $!.nil?

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
    #   description: Wrong argument type <class> (expected Hash)
    #
    # ArgumentError
    #   description: Output filename (:filename) not defined in argument hash
    #
    # ArgumentError
    #  description: Wrong argument type <class> for output filename (expected String)
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

        $logger.behaviour "FAIL;Failed to capture screen.;#{ id.to_s };sut;{};capture_screen;#{ arguments.kind_of?( Hash ) ? arguments.inspect : arguments.class.to_s }"

        raise

      end

      $logger.behaviour "PASS;Screen was captured successfully.;#{ id.to_s };sut;{};capture_screen;#{ arguments.inspect }"

      nil

    end

    # == description
    # Instructs the SUT to start the specified application if it is not currenly being executed
    # The application will also be brought to the foregound.
    #
    # == arguments
    # target
    #  Hash
    #   description: Used to indetify the application to be executed. All symbols defined in the hash must match with the launched application. See application [link="#run_hash_arguments"]run argument hash keys[/link] table.
    #   example: { :name => "calculator" }
    #  String
    #   description: If target application is given in String format it is interpreted as application name. String "calculator"' is equivalent to {:name => "calculator"} hash.
    #   example: "calculator"
    #
    # == tables
    # run_hash_arguments
    #  title: Run argument hash keys
    #  description: The following symbols can be defined in the hash, at least one them must be defined.
    #  |Key|Type|Description|Example|
    #  |:uid|String or Integer|Unique ID of the application|{ :uid => 268458181 }|
    #  |:name|String|Executable name of the application|{ :name => 'calculator' }|
    #  |:restart_if_running|Boolean|Restart application if already running|{ :restart_if_running => true }|
    #  |:arguments|String|Comma separated list of arguments passed to the application when it is started|{ :arguments => '--nogui,-v' }|
    #  |:check_pid|Boolean|Overrides default value of SUT parameter :application_check_pid; When set to true, process id is used to test object identification|false|
    #   |:sleep_time|Integer|Number of seconds to sleep immediately after launching the process|{ :sleep_time => 10 }|
    #   |:start_command|String|When set, the run method will execute this command and expect the application provided by the :name key to be launched. Note that applications launched this way can't be sent a Kill message and its start up events and signals may not be recorded.|{ :start_command => 'start_app_batch',:name => 'calculator' }|
    #   |:try_attach|Boolean|If set to true, run will attempt to attach to an existing application with the given name or id. If not found the application will be launched as normal. If more than 1 are found then an exception is thrown|{:try_attach => true, :name => 'calculator'}|
    #   |:environment|String|Environment variables you want to pass to started process, passed as key value pairs separated by '=' and pairs separated by spaces |{ :environment => 'LC_ALL=en SPECIAL_VAR=value' }|
    #   |:events_to_listen|String|List of events you want to start listening to when application starts, passed as comma separated string.  You can retrieve a list of events fired by a test object by first enabling event listening and then using the get_events method. See methods enable_events, get_events and disable_events |{ :events_to_listen => 'Paint,Show' }|
    #   |:signals_to_listen|String|List of signals you want to start listening to when application starts, passed as comma separated string. Check your application class what signals it can emit, or you can use the 'signal' fixture's 'list_signal' method to retrieve an xml string listing all the signals the object can emit.  E.g. xml = @object.fixture('signal', 'list_signals')|{ :signals_to_listen => 'applicationReady()' }|
    #
    # == returns
    # TestObject
    #  description: Test object of the started application
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type <class> for run method (expected Hash)
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
        #orig_interval = sut_parameters[ :refresh_interval ]
        #sut_parameters[ :refresh_interval ] = '0'

        # raise exception if argument type other than hash
        target.check_type( [ String, Hash ], "Wrong argument type $1 for run method (expected $2)" )

        # if target application is given as string, interpret it as application name
        target = { :name => target.to_s } if target.kind_of?( String )

        # default value for missing keys
        target.default = nil

        # raise exception if :uid or :name not found from hash
        target.require_one( [ :uid, :name ], "Required key :uid or :name not found from argument hash" )

        # due to bug #1488
        sleep_time = ( target[ :sleep_after_launch ] || target[ :sleep_time ] ).to_i

        timeout_time = sut_parameters[ :application_synchronization_timeout, '5' ].to_f

        retry_interval = sut_parameters[ :application_synchronization_retry_interval, '0.5' ].to_f

        if target.has_key?( :check_pid )

          check_pid = target[ :check_pid ].check_type [ TrueClass, FalseClass ], 'wrong argument type $1 for SUT#run :check_pid (expected $2)' 
        
        else
                    
          # due to bug #1710; pid checking must be configurable
          check_pid = sut_parameters[ :application_check_pid, false ].to_s.to_boolean( false )

        end

        raise ArgumentError, "Sleep time need to be >= 0" unless sleep_time >= 0

        # try to find an existing app with the current arguments
        if target[ :try_attach ] || target[:restart_if_running]

          app_list = MobyBase::StateObject.new( 

            :source_data => list_apps,
            :parent => nil,
            :test_object_adapter => @test_object_adapter

          )

          # either ID or NAME have been passed to identify the application
          # raise exception if more than one app has been found for this id/name
          # otherwhise attempt to get the application test object

          app_info = find_app(app_list, {:id => target[ :uid ]}) if target[ :uid ] != nil
          app_info = find_app(app_list, {:name => target[ :name ]}) unless app_info

          app = application(:id => app_info.id) if app_info

          if target[:restart_if_running] && app

            # Close the application,
            app.close # (:force_kill => true)

          elsif app
            
            begin

              app.bring_to_foreground

            rescue Exception => e

              $logger.warning "Could not bring app to foreground"

            end

            return app

          end

        end

        if ( target[ :start_command ] != nil )

          raise MobyBase::BehaviourError.new("Run", "Failed to load execute_shell_method") unless respond_to?("execute_shell_command")

          execute_shell_command( target[ :start_command ], :detached => "true" )

        else

          # execute the application control service request
          # the run request will return the pid if all goes well
          app_pid = nil

          app_pid = execute_command(
            MobyCommand::Application.new(
              :Run,
              { 
                :application_name => target[ :name ],
                :application_uid => target[ :uid ],
                :sut => self,
                :arguments => target[ :arguments ],
                :environment => target[ :environment ],
                :working_directory => target[ :working_directory ],
                :events_to_listen => target[ :events_to_listen ],
                :signals_to_listen => target[ :signals_to_listen ]
              }
            )
          )

        end

        # do not remove this, unless qttas server & plugin handles the syncronization between plugin registration & first ui state request
        # first ui dump is requested too early and target/server seems not be ready...
        sleep sleep_time if sleep_time > 0
     
        # Now the application id is its PID that we get from the execute_command response
        expected_attributes = { :type => 'application' }

        # fix to bug #1710; pid checking must be configurable
        if check_pid == true
        
          expected_attributes[ :id ] = app_pid unless app_pid.nil?

        end        
                
        expected_attributes[ :FullName ] = target[ :name ] unless target[ :name ].nil?

        # For error reporting
        error_details = target[ :name ].nil? ? "" : "name: " << target[ :name ].to_s
        error_details << ( error_details.empty? ? "" : ", ") << "id: " << target[ :uid ].to_s if !target[ :uid ].nil?

        # Calculate the application name from :FullName ( used later )
        app_name = target[ :name ].nil? ? "" : "name: " << target[ :name ].to_s

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
          expected_attributes.delete( :name )
        end

        # Wait for application to register and then create the application test object
        begin

          MobyUtil::Retryable.until(
            :timeout => timeout_time,
            :interval => retry_interval,
            :exception => MobyBase::ApplicationNotAvailableError) {

            # verify that application is launched and application test object is found from xml
            expected_attributes.delete( :name )

            wait_child(

              # attributes to identify application object
              expected_attributes,

              # timeout to for application synchronization
              timeout_time,

              # wait retry interval and try again if application was not found
              retry_interval

            )

            expected_attributes[ :name ] = app_name
            # retrieve application object element from sut.xml_data

            @matches, unused_rule = @test_object_adapter.get_objects( xml_data, expected_attributes, true )

            # raise exception if application element was not found; this shouldn't ever happen?
            raise MobyBase::ApplicationNotAvailableError if @matches.count == 0

          }

          # create application test object
          foreground_app = @test_object_factory.make_test_object(

            :parent => self,

            :parent_application => nil,

            :object_attributes_hash => expected_attributes,

            :xml_object => @matches.first

          )

          # store application reference to test application; this will be passed to it's child test object(s)
          foreground_app.instance_variable_set( :@parent_application, foreground_app )

          # application was not found; this scenario shouldn't ever happen?
          #raise MobyBase::TestObjectNotFoundError unless foreground_app.kind_of?( MobyBehaviour::Application )

        rescue MobyBase::TestObjectNotFoundError

          raise MobyBase::VerificationError, "No application type test object was found on the device after starting the application."

        rescue MobyBase::SyncTimeoutError

          raise MobyBase::VerificationError, "The application (#{ error_details }) was not found on the sut after being launched."

        end

      # raise behaviour error if any exception is raised
      rescue

        $logger.behaviour "FAIL;Failed to launch application.;#{ id.to_s };sut;{};run;#{ target.kind_of?( Hash ) ? target.inspect : target.class.to_s }"

        raise MobyBase::BehaviourError.new("Run", "Failed to launch application")

      end

      $logger.behaviour "PASS;The application was launched successfully.;#{ id.to_s };sut;{};run;#{ target.inspect }"

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

        if value.kind_of?( Symbol )

          sequence = MobyCommand::KeySequence.new( value )
        
        else

          sequence = value
        
        end

        sequence.set_sut( self )

        execute_command( sequence )

      rescue

        $logger.behaviour "FAIL;Failed to press key(s).;#{id.to_s};sut;{};press_key;#{ value }"

        raise

      end

      $logger.behaviour "PASS;Successfully pressed key(s).;#{ id.to_s };sut;{};press_key;#{ value }"

      nil

    end

    # == description
    # Wrapper function to access sut specific parameters.
    # Parameters for each sut are stored in the parameters xml file under group tag with name attribute matching the SUT id
    #
    # == arguments
    # *arguments
    #  String
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
    # TDriver::ParameterHash
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

        $parameters[ @id ]

      else

        $parameters[ @id ][ *arguments ]

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
    #   description: Optional numeral replacement of an '%Ln | %1 | %D | %U | %N' tag on the translated string
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

      raise LogicalNameNotFoundError, "Logical name is nil" if logical_name.nil?

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

        language = nil

        if ( sut_parameters[ :read_lang_from_app ]=='true')

          #read localeName app
          language = application.attribute("localeName")

          #determine the language from the locale
          language = language.split('_')[0].to_s if (language!=nil && !language.empty?)

        else

          language = sut_parameters[ :language ]

        end

        raise LanguageNotFoundError, "Language cannot be determind to perform translation" if ( language.nil? || language.empty? )

        translation = MobyUtil::Localisation.translation(
          logical_name,
          language,
          sut_parameters[ :localisation_server_database_tablename ],
          file_name,
          plurality,
          lengthvariant
        )

        if translation.kind_of? String and !numerus.nil?

          if numerus.kind_of? Array

            translation.gsub!(/%[L]?(\d)/){|s| numerus[($1.to_i) -1] }

          elsif numerus.kind_of? String or numerus.kind_of? Integer

            translation.gsub!(/%(Ln|1|U|D|N)/){|s| numerus.to_s}

          end

        elsif translation.kind_of? Array and !numerus.nil?

          translation.each do |trans|

            if numerus.kind_of? Array

              trans.gsub!(/%[L]?(\d)/){|s| numerus[($1.to_i) -1] }

            elsif numerus.kind_of? String or numerus.kind_of? Integer

              trans.gsub!(/%(Ln|1|U|D|N)/){|s| numerus.to_s}

            end

          end

        end

        translation

      end

    end

    # == nodoc
    # == description
    # Translates all symbol values in hash using SUT's translate method.
    #
    # == arguments
    # hash
    #  Hash
    #   description: containing key and value pairs. The hash will get modified if symbols are found from values
    #   example: {:text=>:translate_me}
    #
    # == returns
    # Hash
    #  description: Translated hash
    #  example: {:text=>'translated_text'}
    # == exceptions
    # LanguageNotFoundError
    #   description: In case of language is not found
    #
    # LogicalNameNotFoundError
    #  description: In case of logical name is not found for current language
    #
    # MySqlConnectError
    #  description: In case problems with the db connectivity
    #
    def translate_values!( hash, file_name = nil, plurality = nil, numerus = nil, lengthvariant = nil )

      hash.each_pair do | _key, _value |

        next if [ :name, :type, :id ].include?( _key )

        hash[ _key ] = translate( _value, file_name, plurality, numerus, lengthvariant ) if _value.kind_of?( Symbol )

      end unless hash.nil?

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
        sut_parameters[ :language ],

        # table name
        sut_parameters[ :user_data_server_database_tablename ]

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
        sut_parameters[ :operator_selected ],

        # table name
        sut_parameters[ :operator_data_server_database_tablename ]

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

      if @update_childs

        @child_object_cache.each_object{ | test_object |

          test_object.send( :update, @xml_data )

          #test_object.update( @xml_data )

        }

        @update_childs = false

        # childs were updated
        true

      else

        # nothing was updated
        false

      end

    end

    # == nodoc
    def refresh( refresh_args = {}, creation_attributes = {} )

      refresh_ui_dump( refresh_args, creation_attributes )

      # update childs if required, returns true or false
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
      matches, unused_rule = @test_object_adapter.get_objects( xml_data, { :type => 'application' }, true )

      # retrieve id attribute if application test object found
      if matches.count > 0

        # return id attribute value
        @test_object_adapter.test_object_element_attribute( matches.first, 'id' )

      else

        # application not found
        '-1'

      end

    end
    
    # == nodoc
    # == description
    # == returns
    def agent

      # pass agent command service object          
      TDriver::AgentService.new( :sut => self )
    
    end

    # == nodoc
    # == description
    # == returns
    def use_find_objects=( value )
    
      value.check_type [ TrueClass, FalseClass ], 'wrong argument type $1 for use_find_objects (expected $2)'
      
      sut_parameters[:use_find_object] = value
      
      #@use_find_objects = value
    
    end

    # == nodoc
    # == description
    # == returns
    def use_find_objects
        
      sut_parameters[:use_find_object, false].true? && respond_to?('find_object').true?

=begin        
      begin
      
        @use_find_objects = ( sut_parameters[ :use_find_object, false ].true? && respond_to?( 'find_object' ).true? ) if @use_find_objects.nil?
              
      rescue
      
        @use_find_objects = false
      
      end

      @use_find_objects
=end
    
    end

  private

    # TODO: document me
    def update_childs

      # update childs only if ui state is new
      update if @update_childs

    end

    # == nodoc
    # Function asks for fresh xml ui data from the device and stores the result
    # == returns
    # MobyUtil::XML::Element:: xml document containing valid xml fragment describing the current state of the device
    def refresh_ui_dump( refresh_args = {}, creation_attributes = [] )

      current_time = Time.now

      unless @frozen

        # determine should FindObjects service be used
        #use_find_objects =  sut_parameters[ :use_find_object, 'false' ] == 'true' and respond_to?( 'find_object' ) == true

        # duplicate refresh arguments hash
        refresh_arguments = refresh_args.clone

        MobyUtil::Retryable.while(

          :tries => @refresh_tries, :interval => @refresh_interval, :unless => [ MobyBase::ControllerNotFoundError, MobyBase::CommandNotFoundError, MobyBase::ApplicationNotAvailableError ]

        ){

          # store as local variable for less AST lookups
          xml_data_checksum = @xml_data_checksum

          # use find_object if set on and the method exists
          if use_find_objects

            # retrieve new ui dump xml and checksum
            new_xml_data, new_checksum = find_object( refresh_arguments, creation_attributes, xml_data_checksum )

            new_checksum = xml_data_checksum if new_xml_data.empty?

          else

            # retrieve new ui dump xml and checksum
            new_xml_data, new_checksum = execute_command(  
            
              MobyCommand::Application.new(
                :State,
                {
                  :application_name => refresh_args[ :FullName ] || refresh_args[ :name ],
                  :application_uid => refresh_args[ :id ],
                  :sut => self,
                  :refresh_arguments => refresh_args,
                  :checksum => xml_data_checksum
                }
              )
            
            )

            new_checksum = xml_data_checksum if new_xml_data.empty?

          end

          # parse the xml if checksum does not match with previously retrieved checksum
          if ( xml_data_checksum == 0 || new_checksum != xml_data_checksum || new_checksum.blank? )

            # parse new xml string, return cached object if one is found; checksum is used for caching and identifying the duplicate xml strings
            xml_data, from_cache = MobyUtil::XML.parse_string( new_xml_data, new_checksum )

            # store new xml data object
            @xml_data = xml_data

            # store xml checksum to be compared while next ui dump request; do not reparse xml if checksum values are equal
            @xml_data_checksum = new_checksum

            # mark that child objects needs to be updated 
            @update_childs = true #unless from_cache

          end

          # increase number of sent ui dump requests by one
          @dump_count += 1

          # store timestamp of last performed ui dump request 
          @_previous_refresh = Time.now

        }

      end

      @xml_data
      
    end

    # TODO: document me
    # Usage disable for now.
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

=begin
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
=end

              subdata =
                MobyUtil::XML.parse_string(
                execute_command(
                  MobyCommand::Application.new(
                    :State,
                    {
                      :application_uid => pid,
                      :sut => self,
                      :flags => {
                        'x_parent_absolute' => x_prev,
                        'y_parent_absolute' => y_prev,
                        'embedded' => 'true',
                        'parent_size' => winSize
                      }
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

    def load_verify_blocks( filename )

      # load verify blocks if filename not empty
      unless filename.blank?

        # verify that file exists
        if File.exists?( filename )

          # load verify blocks configuration file
          load filename

          # return collection of verify blocks; reference directly to VERIFY_BLOCKS must not be used, due to it may get cleared by user
          SutParameters::VERIFY_BLOCKS.collect{ | block | block }

        else
        
          # return empty array due to file didn't exist
          []
        
        end

      else
      
        # return empty array due to no filename was given
        []
      
      end

    end

    # accessor for sut parameters
    def sut_parameters
    
      $parameters[ @id ]
    
    end

  public # deprecated

    # == nodoc
    # function to get TestObject
    # TODO: Still under construction. Should be able to create single descendant of the SUT
    # Then is Should create path (parent-child-child-child...) until reaching the particular TestObject
    # TODO: Document me when I'm ready
    def get_object( object_id )

      warn "warning: deprecated method SUT#get_object; please use SUT#child instead"

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

      refresh_ui_dump( refresh_args, {} )

    end

    # This method is deprecated, please use [link="#GenericSut:state_object"]SUT#state_object[/link] instead.
    # == deprecated
    # 1.1.1
    #
    # == description
    # This method is deprecated, please use SUT#state_object
    #
    def state

      warn "warning: deprecated method SUT#state; please use SUT#state_object instead"

      state_object

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # SUT

end # MobyBehaviour
