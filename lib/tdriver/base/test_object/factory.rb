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

    # TODO: Document me (TestObjectFactory::initialize)
    def initialize

      # get timeout from parameters, use default value if parameter not found
      @timeout = $parameters[ :application_synchronization_timeout, "20" ].to_f

      # get timeout retry interval from parameters, use default value if parameter not found
      @_retry_interval = $parameters[ :application_synchronization_retry_interval, "1" ].to_f

    end

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

    # TODO: document me
    def identify_object( rules )
  
      # retrieve test object identification directives; e.g. :__index, :__xy_sorting etc 
      directives = rules[ :identification_directives ]
      
      # retrieve sut object
      sut = rules[ :parent ].instance_variable_get( :@sut )

      # search parameters for find_objects feature    
      search_parameters = make_object_search_params( rules[ :parent ], rules[ :object_attributes_hash ] )
            
      # default rules      
      directives.default_values(
      
        # get timeout from rules hash or TestObjectFactory
        :__timeout => @timeout,

        # get retry interval from rules hash or TestObjectFactory
        :__retry_interval => @_retry_interval,
         
        # determine that are we going to retrieve multiple test objects or just one
        :__multiple_objects => false,

        # determine that should all child objects childrens be retrieved
        :__find_all_children => true,

        # determine that did user give index value
        :__index_given => directives.has_key?( :__index ),

        # use sorting if index given
        :__xy_sorting => directives.has_key?( :__index ),

        # determine index of test object to be retrieved
        :__index => 0
                         
      )
       
      # identify objects until desired matches found or timeout exceeds
      MobyUtil::Retryable.until( 

        # maximum time used for retrying, if timeout exceeds pass last raised exception
        :timeout => directives[ :__timeout ], 

        # interval used before retrying
        :interval => directives[ :__retry_interval ],

        # following exceptions are allowed; Retry until timeout exceeds or other exception type is raised
        :exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ]

      ){

        # refresh sut
        sut.refresh( directives[ :__refresh_arguments ], search_parameters )


        
        # retrieve objects from xml
        matches, rule = TDriver::TestObjectAdapter.get_objects(
        
         rules[ :parent ].xml_data, 
         rules[ :object_attributes_hash ], 
         directives[ :__find_all_children ] 

        )
        
        # If retrying and regexp search is turned on then update the rules for text search converting it to a regex 
        if ( 
              matches.empty? and 
              $parameters[ sut.id ][:elided_search, 'false'] == 'true' and 
              rules[ :object_attributes_hash ].has_key?(:text) and
              rules[ :object_attributes_hash ][ :text ].kind_of? String
          )
            text_string = rules[ :object_attributes_hash ][ :text ]
            if ( $parameters[ sut.id ][:elided_search_with_ellipsis , 'false'] == 'true' )
              ellipsis_char = ".*\xE2\x80\xA6"  # unicode \u2026 the ... character \xE2\x80\xA6
            else
              ellipsis_char = ""
            end
            elided_regex = Regexp.new( text_string[0..3] + ellipsis_char )
            rules[ :object_attributes_hash ][ :text ] = elided_regex
        end
        
        # raise exception if no matching object(s) found
        raise MobyBase::TestObjectNotFoundError, "Cannot find object with rule:\n#{ rules[ :object_attributes_hash ].inspect }" if matches.empty?

        # raise exception if multiple matches found and only one expected 
        if ( !directives[ :__multiple_objects ] ) && ( matches.count > 1 && !directives[ :__index_given ] )

          # raise exception (with list of paths to all matching objects) if multiple objects flag is false and more than one match found
          raise MobyBase::MultipleTestObjectsIdentifiedError, "Multiple test objects found with rule: #{ rules[ :object_attributes_hash ].inspect }\nMatching objects:\n#{ list_matching_test_objects_as_list( matches ) }\n"
            
        end

        # sort matches if enabled
        if directives[ :__xy_sorting ] == true
                  
          # sort elements
          TDriver::TestObjectAdapter.sort_elements( 
            matches, 
            TDriver::TestObjectAdapter.application_layout_direction( sut )
          )

        end

        # return result; one or multiple xml elements
        if directives[ :__multiple_objects ] && !directives[ :__index_given ]
        
          # return multiple test objects
          matches.to_a

        else

          # return only one test object  
          [ matches[ directives[ :__index ] ] ]

        end

      }
        
    end

    # TODO: document me
    def get_test_objects( rules )

      # store rules hash to variable
      object_attributes_hash = rules[ :object_attributes_hash ].clone

      # remove test object identification directives for object identification attributes hash (e.g. :__index, :__multiple_objects etc.)
      identification_directives = rules[ :identification_directives ]
       
      # verify given identification directives, only documented end-user directives is checked
      identification_directives.each{ | key, value |
      
        # do not verify type by default
        type = nil
      
        case key

          # Fixnum          
          when :__index, :__timeout

            # for backward compatibility          
            if value.kind_of?( String )
            
              warn "warning: deprecated variable type String for #{ key.inspect } test object identification directive (expected TrueClass or FalseClass)"          
          
              raise ArgumentError, "deprecated and wrong variable content format for #{ key.inspect } test object identification directive (expected Numeric string)" unless value.numeric?
          
              value = value.to_i
              
            end
          
            type = Fixnum
                    
          when :__logging, :__xy_sorting

            # for backward compatibility          
            if value.kind_of?( String )
              
              warn "warning: deprecated variable type String for #{ key.inspect } test object identification directive (expected TrueClass or FalseClass)"          

              value = value.to_boolean 
              
            end
          
            type = [ TrueClass, FalseClass ]
          
        end

        # verify hash value if type defined 
        value.check_type( type, "wrong variable type $1 for #{ key.inspect } test object identification directive (expected $2)" ) unless type.nil?

      }
            
      # do not create refresh arguments hash if already exists
      unless identification_directives.has_key?( :__refresh_arguments )
            
        # create application refresh attributes hash
        if object_attributes_hash[ :type ] == 'application'

          # collect :name, :id and :applicationUid from object_attributes_hash if found
          identification_directives[ :__refresh_arguments ] = object_attributes_hash.collect_keys( :name, :id, :applicationUid )

        else
                            
          if rules[ :parent ].kind_of?( MobyBase::TestObject )

            # get current application for test object
            identification_directives[ :__refresh_arguments ] = { :id => rules[ :parent ].get_application_id }

          elsif rules[ :parent ].kind_of?( MobyBase::SUT )
          
            # get current application for sut
            identification_directives[ :__refresh_arguments ] = { :id => rules[ :parent ].current_application_id }

          end
          
        end

      end
      
      # add object identification attribute keys to dynamic attributes white list
      MobyUtil::DynamicAttributeFilter.instance.add_attributes( object_attributes_hash.keys )

      child_objects = identify_object( rules ).collect{ | test_object_xml |
                
        # create parent application test object if none defined in rules; most likely the call is originated from SUT#child, but not by using SUT#application
        unless identification_directives.has_key?( :__parent_application ) || rules.has_key?( :parent_application )
              
          # retrieve application test object xml element
          application_test_object_xml = TDriver::TestObjectAdapter.retrieve_parent_application( test_object_xml )

          unless application_test_object_xml.nil?

            # retrieve sut object
            sut = rules[ :parent ].instance_variable_get( :@sut )

            # retrieve test object id from xml
            object_id = TDriver::TestObjectAdapter.test_object_element_attribute( application_test_object_xml, 'id' ){ nil }.to_i

            # retrieve test object name from xml
            object_name = TDriver::TestObjectAdapter.test_object_element_attribute( application_test_object_xml, 'name' ){ nil }.to_s

            # retrieve test object type from xml
            object_type = TDriver::TestObjectAdapter.test_object_element_attribute( application_test_object_xml, 'type' ){ nil }.to_s 
              
            # calculate object cache hash key
            hash_key = TDriver::TestObjectAdapter.test_object_hash( object_id, object_type, object_name )
              
            parent_cache = sut.instance_variable_get( :@child_object_cache )                       
            
            # get cached test object from parents child objects cache if found; if not found from cache pass newly created object as is
            if parent_cache.has_object?( hash_key )

              rules[ :parent_application ] = parent_cache[ hash_key ]
              
            else
              
              # create application test object            
              rules[ :parent_application ] = make_test_object( 
            
                :parent => sut,          
                :parent_application => nil,
                :xml_object => application_test_object_xml
            
              )
              
            end

          else

            # could not retrieve parent application object
            rules[ :parent_application ] = nil
          
          end

          # store application test object to new test object 
          rules[ :parent_application ].instance_variable_set( :@parent_application, rules[ :parent_application ] )
          
        end
        
        # create new test object
        make_test_object( 
        
          # test objects parent test object
          :parent => rules[ :parent ],

          # test objects parent application 
          :parent_application => rules[ :parent_application ],

          # xml element to test object
          :xml_object => test_object_xml,

          # object identification attributes
          :object_attributes_hash => object_attributes_hash

        )
                 
      }

      # return test object(s); either one or multiple objects
      identification_directives[ :__multiple_objects ] ? child_objects : child_objects.first

    end

    # TODO: document me
    def make_test_object( rules )
                  
      # get parent object from hash
      parent = rules[ :parent ]

      # retrieve sut object
      sut = parent.instance_variable_get( :@sut )
      
      # xml object element      
      xml_object = rules[ :xml_object ]

      # retrieve attributes
      #TDriver::TestObjectAdapter.fetch_attributes( xml_object, [ 'id', 'name', 'type', 'env' ], false )

      if xml_object.kind_of?( MobyUtil::XML::Element )

        # retrieve test object id from xml
        object_id = TDriver::TestObjectAdapter.test_object_element_attribute( xml_object, 'id' ){ nil }.to_i

        # retrieve test object name from xml
        object_name = TDriver::TestObjectAdapter.test_object_element_attribute( xml_object, 'name' ){ nil }.to_s

        # retrieve test object type from xml
        object_type = TDriver::TestObjectAdapter.test_object_element_attribute( xml_object, 'type' ){ nil }.to_s 

        # retrieve test object type from xml
        env = TDriver::TestObjectAdapter.test_object_element_attribute( xml_object, 'env' ){ $parameters[ sut.id ][ :env ] }.to_s
        
      else
      
        # defaults - refactor this
        object_type = ""
        
        object_name = ""
        
        object_id = 0

        env = $parameters[ sut.id ][ :env ].to_s

      end
      
      # calculate object cache hash key
      hash_key = TDriver::TestObjectAdapter.test_object_hash( object_id, object_type, object_name )
      
      # get reference to parent objects child objects cache
      parent_cache = rules[ :parent ].instance_variable_get( :@child_object_cache )

      # get cached test object from parents child objects cache if found; if not found from cache pass newly created object as is
      if parent_cache.has_object?( hash_key )

        # get test object from cache
        test_object = parent_cache[ hash_key ]

        # store xml_object to test object
        test_object.xml_data = xml_object

      else
        
        # create test object
        test_object = MobyBase::TestObject.new( self, sut, parent, xml_object )

        #test_object.instance_variable_set( :@object_behaviours, [] )

        # apply all test object related behaviours unless object type is 'application'
        object_type << ';*' unless object_type == 'application'

        # apply behaviours to test object
        MobyBase::BehaviourFactory.instance.apply_behaviour!(

          :object => test_object,
          :object_type => [ *object_type.split(';') ], 
          :input_type => [ '*', sut.input.to_s ],
          :env => [ '*', *env.to_s.split(";") ],
          :version => [ '*', sut.ui_version.to_s ]

        )
        # create child accessors
        TDriver::TestObjectAdapter.create_child_accessors!( xml_object, test_object )

        # set given parent in rules hash as parent object for new child test object    
        test_object.instance_variable_set( :@parent, parent )

        # set given application test object in rules hash as parent application for new child test object
        test_object.instance_variable_set( :@parent_application, rules[ :parent_application ] )

        # add created test object to parents child objects cache
        parent_cache.add_object( test_object ) 

      end

      # NOTE: Do not remove object_type from object attributes hash_rule due to it is used in find_objects service!
      #rules[ :object_attributes_hash ].delete( :type )

      # update test objects creation attributes (either cached object or just newly created child object)
      test_object.instance_variable_set( :@creation_attributes, rules[ :object_attributes_hash ] )
  
      # do not make test object verifications if we are operating on the sut itself (allow run to pass)
      unless parent.kind_of?( MobyBase::SUT )

        # verify ui state if any verifycation blocks given
        TDriver::TestObjectVerification.verify_ui_dump( sut ) unless sut.verify_blocks.empty?

      end

      # return test object
      test_object

    end

    # create test object search parameters for find_objects service
    def make_object_search_params( test_object, creation_attributes )

      result = get_parent_params( test_object ).push( get_object_params( creation_attributes ) )

      # TODO: review find_objects controller
      # workaround? return empty hash if no search params were 
      result == [{}] ? {} : result

    end

  private 

    # TODO: document me
    def get_object_params( creation_attributes )

      if creation_attributes[ :type ] != 'application'
        
        object_search_params = creation_attributes.clone

        object_search_params[ :className  ] = object_search_params.delete( :type ) if creation_attributes.has_key?( :type )
        object_search_params[ :objectName ] = object_search_params.delete( :name ) if creation_attributes.has_key?( :name )

        object_search_params

      else
      
        {}
      
      end    
    
    end

    # TODO: document me
    def get_parent_params( test_object )

      unless [ 'application', 'sut' ].include?( test_object.type ) 

        search_params = []
      
        search_params.concat( get_parent_params( test_object.parent ) ) if test_object.parent
        search_params.concat( [ :className => test_object.type, :tasId => test_object.id ] ) #if test_object
        
        search_params
        
      else
      
        []
      
      end

    end

    # TODO: document me
    def list_matching_test_objects( matches )

      matches.collect{ | object |
          
        path = [ object.attribute( 'type' ) ]

        while object.attribute( 'type' ) != 'application' do
        
          # object/objects/object/../..
          object = object.parent.parent
          
          path << object.attribute( 'type' )
        
        end

        path.reverse.join( '.' )
      
      }.sort
    
    end

    # TODO: document me
    def list_matching_test_objects_as_list( matches )

      list_matching_test_objects( matches ).each_with_index.collect{ | object, object_index | "%3s) %s" % [ object_index + 1, object ] }.join( "\n" )

    end

  public # deprecated methods

    def set_timeout( new_timeout )

      warn "warning: deprecated method TestObjectFactory#set_timeout( value ); please use TestObjectFactory#timeout=( value ) instead"

      self.timeout = new_timeout

    end

    # Function gets the timeout used in TestObjectFactory
    #
    # === returns
    # Numeric:: Timeout
    def get_timeout

      warn "warning: deprecated method TestObjectFactory#get_timeout; please use TestObjectFactory#timeout instead"

      @timeout

    end

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # TestObjectFactory

end # MobyBase
