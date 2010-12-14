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
module TDriver

  class TestObjectFactory

    attr_reader :test_object_adapter, :timeout, :retry_interval

    # TODO: move to test object adapter
    # TODO: This method should be in application test object
    def get_layout_direction( sut )

      sut.xml_data.at_xpath('*//object[@type="application"]/attributes/attribute[@name="layoutDirection"]/value/text()').to_s || 'LeftToRight'

    end

    def initialize( options )

      @test_object_adapter = options[ :test_object_adapter ]

      @timeout = options[ :timeout ] || MobyUtil::Parameter[ :application_synchronization_timeout, "20" ].to_i

      @retry_interval = options[ :retry_interval ] || MobyUtil::Parameter[ :application_synchronization_retry_interval, "1" ].to_i
    
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

    def retry_interval=( value )

      value.check_type( Numeric, "Wrong argument type $1 for timeout retry interval value (expected $2)" )

      @retry_interval = value

    end

    # TODO: document me
    def get_test_objects( rules )

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
        :__retry_interval => @retry_interval,

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
        make_test_object( 
        
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

    # TODO: document me
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
        if identification_directives[ :__multiple_objects ] && !identification_directives[ :__index_given ]

          # return multiple test objects
          matches.to_a

        else

          # return only one test object  
          [ matches[ identification_directives[ :__index ] ] ]

        end

      }
        
    end

    def make_test_object( rules )

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
          #:sut_type     => [ '*', sut.ui_type ],
          :input_type   => [ '*', sut.input.to_s ],
          :env          => [ '*', *env.split(";") ],	   
          :version      => [ '*', sut.ui_version ]								   
        )

        # create child accessors
        TDriver::TestObjectAdapter.create_child_accessors!( test_object, xml_object )

        # set given parent in rules hash as parent object to new child test object    
        test_object.instance_variable_set( :@parent, parent )

        # add created test object to parents child objects cache
        parent_cache.add_object( test_object ) 

      end

      # update test objects creation attributes (either cached object or just newly created child object)
      test_object.instance_variable_set( :@creation_attributes, rules[ :object_attributes_hash ].clone )
  
      # do not make test object verifications if we are operating on the 
      # base sut itself (allow run to pass)
      unless parent.kind_of?( MobyBase::SUT )

        TDriver::TestObjectVerification.verify_ui_dump( sut ) unless sut.verify_blocks.empty?

      end

      test_object

    end

    def make_object_search_params( creation_attributes )

      if creation_attributes[ :type ] != 'application'
        
        object_search_params = creation_attributes.clone

        object_search_params[ :className ] = object_search_params.delete( :type ) if creation_attributes.has_key?( :type )
        object_search_params[ :objectName ] = object_search_params.delete( :name ) if creation_attributes.has_key?( :name )

        object_search_params

      else
      
        {}
      
      end    

    end

    def get_parent_params( test_object )

      unless [ 'application', 'sut' ].include?( test_object.type ) 
      
        search_params.concat( get_parent_params( test_object.parent ) ) if test_object.parent         
        search_params.concat( [ { :className => test_object.type, :tasId => test_object.id } ] ) #if test_object
        
        search_params
        
      else
      
        []
      
      end

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
  
  end # TestObjectFactory

end # TDriver


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

      # TODO maybe set elsewhere used for defaults
      # TODO: Remove from here, to be initialized by the environment.

      reset_timeout

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
        if identification_directives[ :__multiple_objects ] && !identification_directives[ :__index_given ]
        
          # return multiple test objects
          matches.to_a

        else

          # return only one test object  
          [ matches[ identification_directives[ :__index ] ] ]

        end

      }
        
    end

    # TODO: document me
    def get_test_objects( rules )

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
        make_test_object( 
        
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

    def make_object_search_params( creation_attributes )

      if creation_attributes[ :type ] != 'application'
        
        object_search_params = creation_attributes.clone

        object_search_params[ :className ] = object_search_params.delete( :type ) if creation_attributes.has_key?( :type )
        object_search_params[ :objectName ] = object_search_params.delete( :name ) if creation_attributes.has_key?( :name )

        object_search_params

      else
      
        {}
      
      end    

    end

    def get_parent_params( test_object )

      unless [ 'application', 'sut' ].include?( test_object.type ) 

        search_params = []
      
        search_params.concat( get_parent_params( test_object.parent ) ) if test_object.parent         
        search_params.concat( [ { :className => test_object.type, :tasId => test_object.id } ] ) #if test_object
        
        search_params
        
      else
      
        []
      
      end

    end

  private 

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

    # TODO: This method should be in application test object
    def get_layout_direction( sut )

      sut.xml_data.at_xpath('*//object[@type="application"]/attributes/attribute[@name="layoutDirection"]/value/text()').to_s || 'LeftToRight'

    end

    def make_test_object( rules )

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
          #:sut_type     => [ '*', sut.ui_type ],
          :input_type   => [ '*', sut.input.to_s ],
          :env          => [ '*', *env.split(";") ],	   
          :version      => [ '*', sut.ui_version ]								   
        )

        # create child accessors
        TDriver::TestObjectAdapter.create_child_accessors!( test_object, xml_object )

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

        TDriver::TestObjectVerification.verify_ui_dump( sut ) unless sut.verify_blocks.empty?

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

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObjectFactory

end # MobyBase

