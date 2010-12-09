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

module MobyBase

  # class to represent TestObjectFactory.
  #
  # when a SUT asks for factory to create test objects, it shall give reference to the SUT so that 
  # factory can make a call back for SUT object dump (in xml)
  class TestObjectFactory

    include Singleton

    attr_reader :timeout

      # TODO: Document me (TestObjectFactory::check_verify_always_reporting_settings)
      def check_verify_always_reporting_settings()

        @reporter_attached = MobyUtil::Parameter[ :report_attach_continuous_verification_to_reporter, 'false' ]

        @rcv_raise_errors = MobyUtil::Parameter[ :report_continuous_verification_raise_errors, 'true' ]

        @rcv_fail_test_case = MobyUtil::Parameter[ :report_continuous_verification_fail_test_case_on_error, 'true' ]

        @rvc_capture_screen = MobyUtil::Parameter[ :report_continuous_verification_capture_screen_on_error, 'true' ]

      end

      # TODO: Document me (TestObjectFactory::restore_verify_always_reporting_settings)
      def restore_global_verify_always_reporting_settings()

        @reporter_attached = @global_reporter_attached

        @rcv_raise_errors = @rcv_global_raise_errors

        @rcv_fail_test_case = @rcv_global_fail_test_case

        @rvc_capture_screen = @rvc_global_capture_screen

      end

    # TODO: Document me (TestObjectFactory::initialize)
    def initialize

      # TODO maybe set elsewhere used for defaults
      # TODO: Remove from here, to be initialized by the environment.

      reset_timeout

      @global_reporter_attached = MobyUtil::Parameter[ :report_attach_continuous_verification_to_reporter, 'false' ]

      @rcv_global_raise_errors = MobyUtil::Parameter[ :report_continuous_verification_raise_errors, 'true' ]

      @rcv_global_fail_test_case = MobyUtil::Parameter[ :report_continuous_verification_fail_test_case_on_error, 'true' ]

      @rvc_global_capture_screen = MobyUtil::Parameter[ :report_continuous_verification_capture_screen_on_error, 'true' ]

      @test_object_cache = {}

      @inside_verify = false      

    end

    #TODO: Team TE review @ Wheels
    # Function to set timeout for TestObjectFactory
    # This should be used only in unit testing, otherwise should not be used
    # sets timeout used in identifying TestObjects to new timeout
    #
    # == params
    # new_timeout:: Fixnum which defines the new timeout
    # == raises
    # ArgumentError:: if parameter is not kind of Fixnum
    def timeout=( value )

      value.check_type( Numeric, "Wrong argument type $1 for timeout value (expected $2)" )

      @timeout = value

    end

    #TODO: Team TE review @ Engine
    # Function to reset timeout to default
    # This is needed, as TOFactory is singleton.
    # == params
    # --
    # == returns
    # --
    # == raises
    # --
    def reset_timeout()

      @timeout = MobyUtil::Parameter[ :application_synchronization_timeout, "20" ].to_i

      @_retry_interval = MobyUtil::Parameter[ :application_synchronization_retry_interval, "1" ].to_i

    end

    def identify_object( object_attributes_hash, identification_directives, rules )
  
      MobyUtil::Retryable.until( 

        # maximum time used for retrying, if timeout exceeds pass last raised exception
        :timeout => identification_directives[ :__timeout ], 

        # interval used before retrying
        :interval => identification_directives[ :__retry_interval ],

        # following exceptions are allowed; Retry until timeout exceeds or other exception type is raised
        :exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ] 

      ){

        # refresh sut
        identification_directives[ :__sut ].refresh( identification_directives[ :__refresh_arguments ], identification_directives[ :__search_params ] )

        matches, rule = identification_directives[ :__test_object_identificator ].find_objects( 
          identification_directives[ :__parent ].xml_data, 
          identification_directives[ :__find_all_children ]
        )

        # raise exception if no matching object(s) found
        raise MobyBase::TestObjectNotFoundError.new( 
        
          "Cannot find object with rule:\n%s" % rules[ :object_attributes_hash ].inspect

        ) if matches.empty?

        # raise exception if multiple matches found and only one expected 
        if ( !identification_directives[ :__multiple_objects ] ) && ( matches.count > 1 && !identification_directives[ :__index_given ] )

          # raise exception (with list of paths to all matching objects) if multiple objects flag is false and more than one match found
          raise MobyBase::MultipleTestObjectsIdentifiedError.new( 
          
            "Multiple test objects found with rule: %s\nMatching objects:\n%s\n" % [ 
              rules[ :object_attributes_hash ].inspect,
              list_matching_test_objects( matches ).each_with_index.collect{ | object, object_index | "%3s) %s" % [ object_index + 1, object ] }.join( "\n" )
            ]
          ) 
            
        end

        # sort matches
        if identification_directives[ :__xy_sorting ] == true
                
          # sort elements
          identification_directives[ :__test_object_identificator ].sort_elements_by_xy_layout!( 

            matches, 

            get_layout_direction( identification_directives[ :__sut ] ) 
            
          ) 

        end

        # return result
        if identification_directives[ :__multiple_objects ] && !identification_directives[ :__index_given ]

          # return multiple test objects
          matches.to_a

        else

          # return only one test object  
          [ matches[ identification_directives[ :__index ] ] ]

        end

      }
        
    end








    def identify_object2( object_attributes_hash, identification_directives, rules )

      sut = identification_directives[ :__sut ]
      
      parent = identification_directives[ :__parent ]
      
      refresh_arguments = identification_directives[ :__refresh_arguments ]
  
      test_object_identificator = identification_directives[ :__test_object_identificator ]
  
      search_params = identification_directives[ :__search_params ]
  
      find_all_children = identification_directives[ :__find_all_children ]
  
      index_given = identification_directives[ :__index_given ]
  
      multiple_objects = identification_directives[ :__multiple_objects ]
  
      index = identification_directives[ :__index ]
  
      sorting = identification_directives[ :__xy_sorting ]
  
      MobyUtil::Retryable.until( 

        # maximum time used for retrying, if timeout exceeds pass last raised exception
        :timeout => identification_directives[ :__timeout ], 

        # interval used before retrying
        :interval => identification_directives[ :__retry_interval ],

        # following exceptions are allowed; Retry until timeout exceeds or other exception type is raised
        :exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ] 

      ){

        # refresh sut
        sut.refresh( refresh_arguments, search_params )

        matches, rule = test_object_identificator.find_objects( 
          parent.xml_data, 
          find_all_children
        )

        # raise exception if no matching object(s) found
        raise MobyBase::TestObjectNotFoundError.new( 
        
          "Cannot find object with rule:\n%s" % rules[ :object_attributes_hash ].inspect

        ) if matches.empty?

        # raise exception if multiple matches found and only one expected 
        if ( !multiple_objects ) && ( matches.count > 1 && !index_given )

          # raise exception (with list of paths to all matching objects) if multiple objects flag is false and more than one match found
          raise MobyBase::MultipleTestObjectsIdentifiedError.new( 
          
            "Multiple test objects found with rule: %s\nMatching objects:\n%s\n" % [ 
              rules[ :object_attributes_hash ].inspect,
              list_matching_test_objects( matches ).each_with_index.collect{ | object, object_index | "%3s) %s" % [ object_index + 1, object ] }.join( "\n" )
            ]
          ) 
            
        end

        # sort matches
        if sorting
                
          # sort elements
          test_object_identificator.sort_elements_by_xy_layout!( 

            matches, 

            get_layout_direction( sut ) 
            
          ) 

        end

        # return result
        if multiple_objects && !index_given

          # return multiple test objects
          matches.to_a

        else

          # return only one test object  
          [ matches[ index ] ]

        end

      }
        
    end










    # TODO: document me
    def make_object( rules )

      # store rules hash to variable
      object_attributes_hash = rules[ :object_attributes_hash ].clone

      # remove test object identification directives for object identification attributes hash (e.g. :__index, :__multiple_objects etc.)
      identification_directives = rules[ :identification_directives ]
      
      #object_attributes_hash.strip_dynamic_attributes!

      # get parent object
      parent = rules[ :parent ]
      
      # retrieve sut object
      sut = parent.kind_of?( MobyBase::SUT ) ? parent : parent.sut

      # create application refresh attributes hash
      if object_attributes_hash[ :type ] == 'application'

        # collect :name, :id and :applicationUid from object_attributes_hash if found
        refresh_arguments = object_attributes_hash.collect_keys( :name, :id, :applicationUid )

      else
                          
        if parent.kind_of?( MobyBase::TestObject )

          # get current application for test object
          refresh_arguments = { :id => parent.get_application_id }

        elsif parent.kind_of?( MobyBase::SUT )
        
          # get current application for sut
          refresh_arguments = { :id => sut.current_application_id }

        end
        
      end
            
      # set default values 
      identification_directives.default_values(
      
        # associated sut
        :__sut => sut,

        # new child objects parent object
        :__parent => parent,
            
        # get timeout from rules hash or TestObjectFactory
        :__timeout => @timeout,

        # get retry interval from rules hash or TestObjectFactory
        :__retry_interval => @_retry_interval,

        # determine that are we going to retrieve multiple test objects or just one
        :__multiple_objects => false,

        # determine that should all child objects childrens be retrieved
        :__find_all_children => true,

        # determine that did user give index value
        :__index_given => identification_directives.has_key?( :__index ),

        # determine index of test object to be retrieved
        :__index => 0,
        
        :__refresh_arguments => refresh_arguments,
        
        # make search params
        :__search_params => get_parent_params( parent ).push( make_object_search_params( object_attributes_hash ) ),
      
        # test object identificator to be used
        :__test_object_identificator => MobyBase::TestObjectIdentificator.new( object_attributes_hash )
      
      )
      
      identification_directives[ :__index ].check_type( Fixnum, "Wrong value type $1 for :__index test object identification directive (expected $2)" )

      # add object identification attribute keys to dynamic attributes white list
      MobyUtil::DynamicAttributeFilter.instance.add_attributes( object_attributes_hash.keys )

      child_objects = identify_object( object_attributes_hash, identification_directives, rules ).collect{ | test_object_xml |
            
        # create new test object
        make_test_object2( 
        
          # sut object to t_o
          :sut => identification_directives[ :__sut ],      

          # parent object to t_o
          :parent => identification_directives[ :__parent ],   

          # t_o xml
          :xml_object => test_object_xml,                           

          # test object factory
          :test_object_factory => self,                                     

          :object_attributes_hash => object_attributes_hash

        )
                 
      }

      # return test object(s); either one or multiple objects
      identification_directives[ :__multiple_objects ] ? child_objects : child_objects.first

    end


    # Function for dynamically creating methods for accessing child objects of a test object 
    # == params
    # test_object:: test_object where access methods should be added
    # == returns
    # test_object:: test_object with added access methods
    def create_child_accessors!( test_object )

      created_accessors = []

      test_object.xml_data.xpath( 'objects/object' ).each{ | object_element |

        object_type = object_element.attribute( "type" )

        unless created_accessors.include?( object_type ) || object_type.empty? then

=begin
          # define object type accessor method 
          test_object.meta_def object_type do | *rules |

            #raise ArgumentError, "wrong number of arguments (%s for 1)" % rules.count unless rules.count == 1

            raise TypeError, 'parameter <rules> should be hash' unless rules.first.kind_of?( Hash )
          
            rules.first[:type] = object_type
            
            child( rules.first )
          
          end
=end

         test_object.instance_eval(

            "def %s( rules={} ); raise TypeError, 'parameter <rules> should be hash' unless rules.kind_of?( Hash ); rules[:type] = :%s; child( rules ); end;" % [ object_type, object_type ]


          )
          created_accessors << object_type

        end

      }

    end


    def verify_ui_dump( sut )

      return if @inside_verify

      begin

        @inside_verify = true

        logging_enabled = MobyUtil::Logger.instance.enabled

        sut.verify_blocks.each do | verify |

          check_verify_always_reporting_settings()

          begin

            MobyUtil::Logger.instance.enabled = false

            begin
            
              result = verify.block.call( sut )

            rescue Exception => e

              if @rcv_raise_errors=='true' || @reporter_attached=='false'

                raise MobyBase::ContinuousVerificationError.new(
                  "Verification failed as an exception was thrown when the verification block was executed. %s\nDetails: %s\nNested exception:\n%s" % [ verify.source, ( verify.message || "none" ), e.inspect ]
                )
              elsif @reporter_attached=='true' && @rcv_raise_errors=='false'

                TDriverReportAPI::tdriver_report_set_test_case_status('failed') if @rcv_fail_test_case=='true'

                if @rvc_capture_screen=='true'

                  TDriverReportAPI::tdriver_capture_state

                else

                  TDriverReportAPI::tdriver_capture_state(false)
                  
                end

                TDriverReportAPI::tdriver_report_log("Verification failed as an exception was thrown when the verification block was executed. %s\nDetails: %s\nNested exception:\n%s" % [ verify.source, ( verify.message || "none" ), e.inspect ])

                TDriverReportAPI::tdriver_report_log("<hr />")
                MobyUtil::Logger.instance.enabled = logging_enabled
                MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

              end

            end

            unless result == verify.expected

              if @rcv_raise_errors=='true' || @reporter_attached=='false'
              
                raise MobyBase::ContinuousVerificationError.new(
                  "Verification failed. %s\nDetails: %s\nThe block did not return %s. It returned: %s" % [ 
                    verify.source, ( verify.message || "none" ), verify.expected.inspect, result.inspect 
                  ]
                )
                
              elsif @reporter_attached=='true' && @rcv_raise_errors=='false'
              
                TDriverReportAPI::tdriver_report_set_test_case_status('failed') if @rcv_fail_test_case=='true'
                
                if @rvc_capture_screen=='true'
                  TDriverReportAPI::tdriver_capture_state
                else
                  TDriverReportAPI::tdriver_capture_state(false)
                end
                
                TDriverReportAPI::tdriver_report_log(
                  "Verification failed. %s\nDetails: %s\nThe block did not return %s. It returned: %s " % [ 
                    verify.source, ( verify.message || "none" ), verify.expected.inspect, result.inspect
                  ]
                )
                
                TDriverReportAPI::tdriver_report_log("<hr />")
                MobyUtil::Logger.instance.enabled = logging_enabled
                
                MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

              end
            
            end

          rescue Exception => e

            MobyUtil::Logger.instance.enabled = logging_enabled

            MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s

            @inside_verify = false

            Kernel::raise e
          
          end

          # Do NOT report PASS cases, like other verify blocks do. This would clog the log with useless info.
          restore_global_verify_always_reporting_settings()
        
        end

      ensure

        MobyUtil::Logger.instance.enabled = logging_enabled
        @inside_verify = false      

      end
      
    end

    def make_object_search_params( creation_attributes )

      object_search_params = {}

      if creation_attributes[ :type ] != 'application'
      
        object_search_params.merge!( creation_attributes )

        object_search_params[ :className ] = object_search_params.delete( :type ) if creation_attributes.has_key?( :type )

        object_search_params[ :objectName ] = object_search_params.delete( :name ) if creation_attributes.has_key?( :name )

      end    

      object_search_params

    end

    def get_parent_params( test_object )

      search_params = []

      unless [ 'application', 'sut' ].include?( test_object.type ) # if test_object.type != 'application' and test_object.type != 'sut'
      
        search_params.concat( get_parent_params( test_object.parent ) ) if test_object.parent 
        
        search_params.concat( [ { :className => test_object.type, :tasId => test_object.id } ] ) #if test_object
        
      end

      search_params

    end

  private 

    def list_matching_test_objects( matches )

      matches.collect{ | object |
          
        path = [ object.attribute("type") ]

        while object.attribute("type") != 'application' do
        
          # object/objects/object/../..
          object = object.parent.parent
          
          path << object.attribute("type")
        
        end

        path.reverse.join(".")
      
      }.sort
    
    end

    # TODO: This method should be in application test object
    def get_layout_direction( sut )

      sut.xml_data.xpath('*//object[@type="application"]/attributes/attribute[@name="layoutDirection"]/value/text()').first.content || 'LeftToRight'

    end

    def make_test_object2( rules )

      # get test object factory object from hash
      test_object_factory = rules[ :test_object_factory ]
            
      # get sut object from hash
      sut = rules[ :sut ]
      
      # get parent object from hash
      parent = rules[ :parent]
      
      xml_object = rules[ :xml_object ]

      if xml_object.kind_of?( MobyUtil::XML::Element )

        # retrieve test object id from xml
        object_id = xml_object.attribute( 'id' ).to_i

        # retrieve test object name from xml
        object_name = xml_object.attribute( 'name' ).to_s

        # retrieve test object type from xml
        object_type = xml_object.attribute( 'type' ).to_s

        # retrieve test object type from xml
    	  env = ( xml_object.attribute( 'env' ) || MobyUtil::Parameter[ sut.id ][ :env ] ).to_s

      else
      
        # defaults - refactor this
        object_type = ""
        
        object_name = ""
        
        object_id = 0

        env = MobyUtil::Parameter[ sut.id ][ :env ].to_s

      end

      # calculate object cache hash key
			hash_key = ( ( ( 17 * 37 + object_id ) * 37 + object_type.hash ) * 37 + object_name.hash )

      # (DO NOT!!) remove object type from object attributes hash_rule
      #rules[ :object_attributes_hash ].delete( :type )

      # get reference to parent objects child objects cache
      parent_cache = rules[ :parent ].instance_variable_get( :@child_object_cache )

      # get cached test object from parents child objects cache if found; if not found from cache pass newly created object as is
      if parent_cache.has_object?( hash_key )

        # get test object from cache
        test_object = parent_cache[ hash_key ]

        test_object.xml_data = xml_object

      else
      
        test_object = MobyBase::TestObject.new( test_object_factory, sut, parent, xml_object )

        # apply behaviours to test object
        test_object.extend( MobyBehaviour::ObjectBehaviourComposition )

        # apply behaviours to test object
        test_object.apply_behaviour!(
          :object_type  => [ '*', object_type ],
          :sut_type     => [ '*', sut.ui_type ],
          :input_type   => [ '*', sut.input.to_s ],
          :env          => [ '*', env.to_s ],	   
          :version      => [ '*', sut.ui_version ]								   
        )

        create_child_accessors!( test_object )

        # set given parent in rules hash as parent object to new child test object    
        test_object.instance_variable_set( :@parent, parent )

        # add created test object to parents child objects cache
        parent_cache.add_object( test_object ) 

      end

      # update test objects creation attributes (either cached object or just newly created child object)
      test_object.instance_variable_set( :@creation_attributes, rules[ :object_attributes_hash ] )
  
      # do not make test object verifications if we are operating on the 
      # base sut itself (allow run to pass)
      unless parent.kind_of?( MobyBase::SUT )

        verify_ui_dump( sut ) unless sut.verify_blocks.empty?

      end

      test_object

    end

  public # deprecated methods

    def set_timeout( new_timeout )

      warn( "Deprecated method: use timeout=(value) instead of TestObjectFactory#set_timeout( value )" )

      self.timeout = new_timeout

    end

    # Function gets the timeout used in TestObjectFactory
    #
    # === returns
    # Numeric:: Timeout
    def get_timeout

      warn( "Deprecated method: use timeout instead of TestObjectFactory#get_timeout" )

      @timeout

    end

    #TODO: update documetation
    # Function to make a test object.
    # Queries from the sut an xml dump which is used to generate TestObjects.
    # Once XML dump is retrieved, a TestObject is identified by the TestObjectIdentificator.
    # TestObject is populated with data and activated.
    # The behaviour is added, as described in BehaviourGenerator#apply_behaviour
    # Lastly the created TestObject instance is associated to the SUT and vice versa.
    #
    # TODO: proper synchronization
    # 
    # == params
    # sut:: SUT object with which the new test object is to be associated 
    # test_object_identificator:: TestObjectIdentificator which is used to identify the required test object from the xml data
    # == returns
    # TestObject new, initialized and ready to use test object with associated data and behaviours
    # == raises, as defined in TestObjectIdentificator
    # ArgumentError:: if test_object_identificator is not of type LibXML::XML::Node,
    # MultipleTestObjectsIdentifiedError:: if multiple TestObjects can be identified using the test_object_identificator
    # TestObjectNotFoundError:: if no TestObjects are identified using the test_object_identificator
    def make( sut, test_object_identificator )

      test_object = make_test_object( 
        self, 
        sut, 
        sut, 
        _make_xml( sut, test_object_identificator, @timeout, @_retry_interval ) 
      )

      sut.instance_variable_get( :@child_object_cache ).add_object( test_object ) 

      test_object

    end

    # Function to get the xml element for a test object
    # TODO: Remove TestObjectFactory::makeXML function & refactor the 'user' of this function!
    def _make_xml( sut, test_object_identificator, timeout, interval )

      attributes = test_object_identificator.get_identification_rules
          
      if attributes[ :type ] == 'application'

        refresh_args = { :name => attributes[ :name ], :id => attributes[ :id ], :applicationUid => attributes[ :applicationUid ] }

      else
    
        refresh_args = { :id => sut.current_application_id } 

      end
      
      attributes_clone = attributes.clone

      # add symbols to dynamic attributes list -- to avoid IRB bug
      MobyUtil::DynamicAttributeFilter.instance.add_attributes( attributes_clone.keys )

      MobyUtil::Retryable.until(
                    
        :timeout    => timeout, 
        :interval   => interval, 
        :exception  => MobyBase::TestObjectNotFoundError 
        
      ) { 
        
        sut.refresh( refresh_args, [ attributes_clone ] )

        test_object_identificator.find_object_data( sut.xml_data )

      }

    end

    def make_test_object( test_object_factory, sut, parent, xml_object )

      if xml_object.kind_of?( MobyUtil::XML::Element )

        # retrieve test object type from xml
        object_type = xml_object.attribute( 'type' )

        # retrieve test object type from xml
    	  env = xml_object.attribute( 'env' ) || MobyUtil::Parameter[ sut.id ][ :env ]

      else
      
        # defaults - refactor this
        object_type = nil

        env = MobyUtil::Parameter[ sut.id ][ :env ]

      end

      #if !@test_object_cache.has_key?( object_type )

      test_object = MobyBase::TestObject.new( test_object_factory, sut, parent, xml_object )

      # apply behaviours to test object
      test_object.extend( MobyBehaviour::ObjectBehaviourComposition )

      # apply behaviours to test object
      test_object.apply_behaviour!(
        :object_type  => [ '*', object_type ],
        :sut_type     => [ '*', sut.ui_type ],
        :input_type   => [ '*', sut.input.to_s ],
        :env          => [ '*', env.to_s ],								   
        :version      => [ '*', sut.ui_version ]								   
      )
      
=begin
         Removed object cache usage
         # now test object has all required behaviours, store it to cache
         @test_object_cache[ object_type ] = test_object.clone

       else


         # retreieve test object with behaviours from cache and clone it
         ( test_object = @test_object_cache[ object_type ].clone ).instance_exec{

        @test_object_factory = test_object_factory
        @sut = sut
        @parent = parent
        self.xml_data = xml_object

        }

       end
=end
  
      create_child_accessors!( test_object )

      # do not make test object verifications if we are operating on the 
      # base sut itself (allow run to pass)
      unless parent.kind_of?( MobyBase::SUT )

        verify_ui_dump( sut ) unless sut.verify_blocks.empty?

      end

      test_object

    end

    # Function for making a child test object (a test object that is not directly a accessible from the sut) 
    # Creates accessors for children of the new object, applies any behaviours applicable for its type. 
    # Does not associate child object to parent / vice versa - leaves that to the client. 
    #
    # == params
    # parent_test_object:: TestObject thas is the parent of the child object being created 
    # test_object_identificator:: TestObjectIdentificator which is used to identify the child object from the xml data
    # == returns
    # TestObject:: new child test object, could be eql? to an existing TO
    # == raises
    # == raises, as defined in TestObjectIdentificator
    # ArgumentError:: if test_object_identificator is not of type LibXML::XML::Node,
    # MultipleTestObjectsIdentifiedError:: if multiple TestObjects can be identified using the test_object_identificator
    # TestObjectNotFoundError:: The TestObject cannot be found or the parent object is no longer visible on the SUT
    def make_child_objects( rules )

      # make array of matching child test objects
      get_test_objects( rules ).collect{ | test_object_xml |

        make_test_object( 
          self,               # test object factory
          rules[ :sut ],      # sut object to t_o
          rules[ :parent ],   # parent object to t_o
          test_object_xml     # t_o xml
        )

      }

    end

    # TODO: Documentation
    def get_test_objects( rules )

      # get parent object
      parent = rules[ :parent ]

      # determine which application to refresh when identifying desired object(s)
      refresh_arguments = rules.fetch( :application, {} )

      # get associated sut object
      sut = rules.fetch( :sut )

      # determine that are we going to retrieve multiple test objects
      multiple_objects = rules.fetch( :multiple_objects, false )

      # determine that should all child objects childrens be retrieved
      find_all_children = rules.fetch( :find_all_children, true )

      # creation attributes for test object
      creation_attributes = rules.fetch( :attributes )

      # dynamic attributes for test object
      #dynamic_attributes = rules.fetch( :dynamic_attributes )
      dynamic_attributes = rules.fetch( :dynamic_attributes, {} )

      # sorting is disabled by default
      sorting = MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__xy_sorting ], false )

      # determine that did user give index value
      index_given = dynamic_attributes.has_key?( :__index )

      # index for test object, default is 0 (first) if not defined by caller
      index = dynamic_attributes.fetch( :__index, 0 ).to_i

      # create test object identificator object with given creation attributes
      test_object_identificator = MobyBase::TestObjectIdentificator.new( creation_attributes ) 

      # make search params
      # object_search_params = make_object_search_params( creation_attributes )
      # search_params = get_parent_params( parent )
      # search_params.push( object_search_params )

      # make search params
      search_params = get_parent_params( parent ).push( make_object_search_params( creation_attributes ) )

      MobyUtil::Retryable.until( 

        # maximum time used for retrying, if timeout exceeds pass last raised exception
        :timeout => ( rules[ :timeout ] || @timeout ), 

        # interval used before retrying
        :interval => ( rules[ :interval ] || @_retry_interval ),

        # following exceptions are allowed; Retry until timeout exceeds or other exception type is raised
        :exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ] 

      ){

        # refresh sut ui state    
        sut.refresh( refresh_arguments, search_params )

        # identify test objects from xml
        matches, rule = test_object_identificator.find_objects( parent.xml_data, find_all_children )

        # raise exception if no matching object(s) found
        raise MobyBase::TestObjectNotFoundError.new( 
        
          "Cannot find object with rule:\n%s" % creation_attributes.merge( dynamic_attributes ).inspect

        ) if matches.empty?

        if ( !multiple_objects ) && ( matches.count > 1 && !index_given )

          # raise exception (with list of paths to all matching objects) if multiple objects flag is false and more than one match found
          raise MobyBase::MultipleTestObjectsIdentifiedError.new( 
          
            "Multiple test objects found with rule: %s\nMatching objects:\n%s\n" % [ 
              creation_attributes.merge( dynamic_attributes ).inspect,
              list_matching_test_objects( matches ).each_with_index.collect{ | object, object_index | "%3s) %s" % [ object_index + 1, object ] }.join( "\n" )
            ]
          ) 
            
        end

        # sort elements
        test_object_identificator.sort_elements_by_xy_layout!( matches, get_layout_direction( sut ) ) if sorting

        # return result
        multiple_objects && !index_given ? matches.to_a : [ matches[ index ] ]

      }

    end


    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObjectFactory

end # MobyBase
