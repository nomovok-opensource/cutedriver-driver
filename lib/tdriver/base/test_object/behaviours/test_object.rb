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
  # Describes the generic behaviour of TestObject, common methods that can be used to control TestObject
  #
  # == behaviour
  # GenericTestObject
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
  module TestObject

    # == nodoc
    # == description
    # attr_accessor
    # == returns
    # Hash
    #  description: Hash containing the identification attributes that were used when the test object was created.
    #  example: { :name => 'Triangle1', :type => :Triangle }
    attr_accessor :creation_attributes

=begin
    # == description
    # Returns the actual test object that was used as the parent when this object instance was created
    #
    # == returns
    # TestObject
    #   description: test object that was used as parent when this object was created. Can also be of type SUT if sut was the parent (ie. application objects) 
    #   example: -
    attr_reader :parent
=end

=begin
    # == nodoc
    # == description
    # attr_reader
    # == returns
    # Hash
    #  description: Parent application test object
    #  example: <MobyBase::TestObject>
    attr_reader :parent_application
=end

    # == nodoc
    # == description
    # Changes the status of the test object to active
    # == returns 
    # TrueClass::
    # == example
    # @app = @sut.run(:name => 'testapp') # launches testapp 
    # @app.Node( :name => 'Node1' ).activate() # activate given object
    def activate

      @_active = true

    end

=begin
    # == description
    # Determines if the current test object is of type 'application'
    # == returns
    # Boolean
    #  description: Determines is test object type of application 
    #  example: false
    def application?

      @type == 'application'

    end
=end

    # == description
    # Return all test object attributes. Please see [link="#GenericTestObject:[]"][][/link] method for optional approach.
    # == returns
    # Hash
    #  description: Test object attributes
    #  example: {"localeLanguage"=>"English", "startDragDistance"=>"4", "windowIcon"=>"", "memUsage"=>"25669"}
    # == example
    # @test_app = @sut.run(:name => 'testapp') # launches testapp 
    # attributes_hash = @test_app.Triangle( :name => 'Triangle1' ).attributes # retrieve all attribute for triangle object
    def attributes

      # retrieve sut attribute filter type
      filter_type = sut_parameters[ :filter_type, 'none' ] 

      # temporarly disable attribute filter to retrieve all test object attributes
      sut_parameters[ :filter_type ] = 'none'

      begin

        # raise exception to refresh test object ui state if filter_type was something else than 'none'
        raise MobyBase::TestObjectNotFoundError unless filter_type == 'none'

        # retrieve xml data, performs xpath to sut xml_data
        _xml_data = xml_data

      rescue MobyBase::TestObjectNotFoundError

        # attributes used to refresh parent application
        if @creation_attributes[ :type ] == 'application'

          # use application name and id attributes
          refresh_args = { :name => @creation_attributes[ :name ], :id => @creation_attributes[ :id ] }

        else

          # test object if not type of application
          refresh_args = { :id => get_application_id }

        end

        #lets refresh if attribute not found on first attempt
        refresh( refresh_args )

        # retrieve updated xml data
        _xml_data = xml_data

      ensure

        # restore attributes filter type
        sut_parameters[ :filter_type ] = filter_type

      end

      # return hash of test object attributes
      @test_object_adapter.test_object_attributes( _xml_data )

    end

    # == description
    # Function returns a attribute of test object. Please see [link="#GenericTestObject:[]"][][/link] method for optional approach.
    #
    # == arguments
    # name
    #  String
    #   description: String defining the name of the attribute to get
    #   example: "name"
    #
    # == returns
    # String
    #   description: Value of the attribute as a string
    #   example: "value"
    #
    # == exceptions
    # TestObjectNotInitializedError
    #  description: if the test object xml data has not been initialized
    #
    # AttributeNotFoundError
    #   description: if the requested attribute can not be found in the xml data of the object
    #
    # == example
    # @test_app = @sut.run(:name => 'testapp') # launches testapp 
    # puts @test_app.Triangle( :name => 'Triangle1' ).attribute('color') # prints color of triangle object
    def attribute( name )

      # TODO: add behaviour logging?

      # raise exception if attribute name variable type is other than string
      name.check_type( [ String, Symbol ], "wrong argument type $1 for attribute (expected $2)" )
      
      # convert name to string if variable type is symbol
      name = name.to_s if name.kind_of?( Symbol )

      # retrieve attribute value 
      find_attribute( name )

    end

    # == description
    # Wrapper method to returns one or all test object attributes. This method calls [link="#GenericTestObject:attribute"]attribute[/link] or [link="#GenericTestObject:attributes"]attributes[/link] depending on the given argument.
    #
    # == arguments
    # name
    #  String
    #   description: Attribute name
    #   example: "attribute_name"
    #  NilClass
    #   description: Return all attributes
    #   example: nil
    #
    # == returns
    # String
    #   description: Value of the attribute
    #   example: "value"
    #
    # Hash
    #   description: Hash of all attributes
    #   example: {:x=>"0", :y=>"0"}
    #
    def []( name = nil )

      if name.nil?

        attributes

      else

        attribute( name )

      end  

    end

    # == description
    # Returns the parent test object for the current object in question, according to the UI object hierarchy. For getting the test object that was actually used 
    # as the parent when the test object instance was created, see [link="#GenericTestObject:parent"]parent[/link] method.
    # == returns
    # TestObject
    #   description: test object that is parent of this test object, self if no parent (ie. application objects)
    #   example: -
    # == example
    # @app = @sut.run(:name => 'testapp') # launches testapp 
    # parent_test_object = @app.Node( :name => 'Node1' ).get_parent() #get parent for some test object
    def get_parent

      # return current test object if it's type of application
      return self if application?

      @sut.refresh if disable_optimizer

      # retrieve parent of current xml element; objects/object/objects/object/../..
      parent_element = @test_object_adapter.parent_test_object_element( self )

      # retrieve parent element attributes
      parent_attributes = @test_object_adapter.test_object_element_attributes( parent_element )

      if get_application_id && parent_attributes[ 'type' ] != 'application'

        parent = @sut.child( 

          :id => get_application_id, 
          :type => 'application' 

        ).child( 

          :id => parent_attributes[ 'id' ], 
          :name => parent_attributes[ 'name' ], 
          :type => parent_attributes[ 'type' ],

          # there was a case when the same parent was included twice in the ui dump
          :__index => 0 
        )

      else

        parent = @sut.child( 
          :id => parent_attributes[ 'id' ], 
          :name => parent_attributes[ 'name' ],
          :type => parent_attributes[ 'type' ]
        )

      end

      enable_optimizer

      parent

    end
    
    # == nodoc
    # Function refreshes test objects to correspond with the current state of the device.
    # 
    # NOTE:
    #
    # @sut#refresh will call update method for this TestObject, if state has changed. Thus, calling
    # @sut.refresh might have a side effect that changes the @_active instance variable.
    # === raises
    # TestObjectNotFoundError:: if TestObject is not identified within synch timeout.
    def refresh( refresh_args = {} )

      refresh_args.check_type Hash, "wrong argument type $1 for #{ application? ? 'application' : 'test object' } refresh attributes (expected $2)"

      if refresh_args.blank? 

        if application?

          refresh_args = { :name => @name, :id => @id }

        else

          refresh_args = { :name => @parent_application.name, :id => @parent_application.id }

        end

      end

      @sut.refresh( 

        refresh_args, @test_object_factory.make_object_search_params( parent, @creation_attributes )

      )

      # update childs if required, returns true or false
      update( xml_data )

      nil

    end

    # == nodoc
    # Function refreshes test objects to correspond with the current state of the device, forcing
    # the sut to request a new XML dump from the device.
    # 
    # NOTE:
    #
    # @sut#force_refresh will call update method for this TestObject, if state has changed. Thus, calling
    # @sut.force_refresh might have a side effect that changes the @_active instance variable.
    # === raises
    # TestObjectNotFoundError:: if TestObject is not identified within synch timeout.
    def force_refresh( refresh_args = nil )

      refresh_args = @creation_attributes if refresh_args.nil?

      refresh( refresh_args )

    end

    # == description
    # Function for finding out the application this test ojbect
    # == returns
    # MobyBase::TestObject
    #  description: Application test object that the test object belongs to, or nil, if no parent of type application can be found.
    #  example: -
    # == example
    # parent_app = @app.Node( :name => 'Node1' ).get_application() #get application for some test object, this should return @app.
    def get_application

      # test object should have @parent_application always
      return @parent_application if @parent_application

      # workaround: fetch application from sut, this part of code should not be executed ever
      return self if application?

      test_object = @parent

      while test_object

        return test_object if ( test_object.type == 'application' )

        test_object = test_object.parent

      end

      # return application object or nil if no parent found
      # Does is make sense to return nil - should  n't all test objects belong to an application? Maybe throw exception if application not found
      begin 

        @sut.child( :type => 'application' ) 

      rescue 

        nil

      end

    end

    # == nodoc
    # == description
    # Function for finding out the application id for this test object
    # == returns
    # String:: representing the id of the application test object that this test object belongs to.
    # == example
    # puts @app.Node( :name => 'Node1' ).get_application_id() #print the application id, this should print @app.id
    def get_application_id

      if @parent_application

        @parent_application.id

      else

        # workaround
        # What about the case when get_application returns nil? This line will throw an exception in that case.
        get_application.id

      end

    end

    # == nodoc
    def set_application_id( application_id )

      @_application_id = application_id

     end

    # == description
    # Returns a StateObject containing the current state of this test object as XML. The state object is static and thus is not refreshed or synchronized etc.
    #
    # == returns
    # StateObject
    #  description: State of this test object
    #  example: -
    #
    # == exceptions
    # ArgumentError
    #  description: If the xml source for the object cannot be read
    def state_object

      # == example
      # app_state = @sut.application( :name => "calculator" ).state #get the state object for the app
      # button_state = app_state.Button( :text => "Backspace" ) #get the state for test object button
      # button_text = button_state.attribute( "text" ) #get attribute text from the button state object

      MobyBase::StateObject.new( 

        :source_data => xml_data, 
        :parent => self,
        :test_object_adapter => @test_object_adapter

      )

    end

    # == description
    # Creates a child test object of this test object. Caller object will be associated as child test objects parent.\n
    # \n
    # [b]NOTE:[/b] Subsequent calls to TestObject#child( rule ) always returns reference to same Testobject:\n
    # [code]a = to.child( :type => 'Button', :text => '1' )
    # b = to.child( :type => 'Button', :text => '1' )
    # a.eql?( b ) # => true[/code]
    # == arguments
    # attributes
    #  Hash
    #   description: Hash object holding information for identifying which child to create
    #   example: { :type => :slider }
    #
    # == returns
    # MobyBase::TestObject
    #  description: new child test object or reference to existing child
    #  example: -
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type <class> for attributes (expected Hash)
    #
    # MultipleTestObjectsIdentifiedError
    #  description:  raised if multiple objects found that match the given attributes
    #
    # TestObjectNotFoundError
    #  description:  raised if the child object could not be found
    #
    # TestObjectNotVisibleError
    #  description: rasied if the parent test object is no longer visible
    def child( attributes )

      # verify attributes argument format
      attributes.check_type [ Hash, String, Symbol, Regexp, Array ], "wrong argument type $1 for attributes (expected $2)"

      # set rules hash to empty Hash if rules hash is not type of Hash
      unless attributes.kind_of?( Hash ) 

        # pass empty rules hash if no argument given, otherwise assume value to be object name
        if attributes.blank?

          attributes = {}

        else

          attributes = { :name => attributes }

        end

      end

      get_child_objects( attributes )
    
    end
    
    # == description
    # Function similar to child, but returns an array of children test objects that meet the given criteria
    #
    # == arguments
    # attributes
    #  Hash
    #   description: object holding information for identifying which child to create
    #   example: { :type => :slider }
    #  
    # find_all_children
    #  TrueClass
    #   description: Boolean specifying whether all children under the test node or just immediate children should be retreived
    #   example: true
    #  FalseClass
    #   description: Boolean specifying whether all children under the test node or just immediate children should be retreived
    #   example: false
    #   
    # == returns
    # Array
    #   description: An array of test objects
    #   example: [ MobyBase::TestObject, MobyBase::TestObject, MobyBase::TestObject, ... ]
    #
    # == exceptions
    # TypeError
    #  description: raised if agument is not a Hash
    #
    # TestObjectNotFoundError
    #  description: raised if the child object could not be found
    #
    # TestObjectNotVisibleError
    #  description: rasied if the parent test object is no longer visible
    def children( attributes, find_all_children = true )

      # verify attributes argument format
      attributes.check_type( Hash, "wrong argument type $1 for attributes (expected $2)" )

      # verify find_all_children argument format
      find_all_children.check_type( [ TrueClass, FalseClass ], "wrong argument type $1 for find_all_children (expected $2)" )

      # If empty or only special attributes then add :type => '*' to search all
      attributes[ :type ] = '*' if attributes.select{ | key, value | key.to_s !~ /^__/ ? true : false }.empty?

      # children method specific settings
      attributes.merge!( :__multiple_objects => true, :__find_all_children => find_all_children, :__no_caching => true )

      # disable optimizer state if enabled
      #disable_optimizer -> leave it on, tuukka if breaks take it back...

      # retrieve child objects
      result = get_child_objects( attributes )

      # restore optimizer state if it was enabled
      #enable_optimizer

      # return results
      result
    
    end
    
  private

    # == nodoc
    # Updates this test object to match the data in the provided xml document
    # Propagates updating to all child TestObjects
    # If TestObject is not identified, then current TO is deactivated, as is all the Child objects, as defined in TestObject#deactivate.
    # === params
    # xml_document:: MobyUtil::XML::Node describing the new state of this test object
    # === returns 
    # ?
    # === raises
    # nothing
    def update( xml_document )

      begin

        # find object from new xml data
        _xml_data, unused_rule = @test_object_adapter.get_objects( xml_document, { :type => @type, :id => @id, :name => @name }, true )
                        
        # deactivate if test object not found or multiple matches found
        raise unless _xml_data.count == 1 

        # get first matching element
        _xml_data = _xml_data.first

        #unless _xml_data.eql?( xml_data )

          # store previous object environment value 
          previous_environment = @env

          # update current test objects xml_data 
          __send__( :xml_data=, _xml_data )

          # compare new environment value with previous 
          if @env != previous_environment

            # remove cached behaviour module 
            TDriver::BehaviourFactory.reset_cache

            # apply only application behaviours if test object is type of 'application'
            object_type = ( @type == "application" ? [ @type ] : [ '*', @type ] )

            # reapply behaviours to test object if environment value has changed
            TDriver::BehaviourFactory.apply_behaviour(

              :object       => self,
              :object_type  => object_type, 
              :input_type   => [ '*', @sut.input.to_s       ],
              :env          => [ '*', *@env.to_s.split(";") ],
              :version      => [ '*', @sut.ui_version.to_s  ]

            )
            
          end

          # update child objects
          @child_object_cache.each_object{ | test_object | 
          
            # update test object with new xml_data
            #test_object.update( _xml_data ) 
            test_object.send( :update, _xml_data ) 
            
          }
        
        #end
                
      rescue

        # deactivate test object
        deactivate
                      
      end

    end 

    # TODO: document me
    def disable_optimizer

      # disable optimizer for this call since it will not work
      @_enable_optimizer = false

      if sut_parameters[ :use_find_object, 'false' ] == 'true' and @sut.respond_to?( 'find_object' )

        sut_parameters[ :use_find_object ] = 'false'

        @_enable_optimizer = true

      end

      @_enable_optimizer

    end

    # TODO: document me
    def enable_optimizer

      sut_parameters[ :use_find_object ] = 'true' if @_enable_optimizer

      @_enable_optimizer = false

    end

    # TODO: document me
    # Tries to use the missing method id as a child object type and find an object based on it
    def method_missing( method_id, *method_arguments )

      # create rules hash
      rules_hash = method_arguments.first

      # set rules hash to empty Hash if rules hash is not type of Hash
      unless rules_hash.kind_of?( Hash ) 

        # pass empty rules hash if no argument given, otherwise assume value to be object name
        if rules_hash.blank?

          rules_hash = {}

        else

          rules_hash = { :name => rules_hash }

        end

      end

      # set test object type
      rules_hash[ :type ] = method_id.to_s
  
      begin

        # return created child object
        child( rules_hash )

      rescue MobyBase::TestObjectNotFoundError, MobyBase::TestObjectNotVisibleError

        rules_hash_clone = rules_hash.clone

        # remove type attribute from hash        
        rules_hash_clone.delete(:type)

        # string representation of used rule hash, remove curly braces
        attributes_string = rules_hash_clone.inspect[ 1 .. -2 ]
        
        if attributes_string.empty?
        
          # do not show any attribute details if none given                
          attributes_string = ""
          
        else
  
          # show used attributes      
          attributes_string = " (attributes #{ attributes_string })"

        end

        # raise slightly different exception message when receiver test object is type of application
        if application? 

          message = "The application (id: #{ @id }, name: #{ @name.inspect }) has no child object with type or behaviour method with name #{ method_id.to_s.inspect }#{ attributes_string } on #{ @sut.id.inspect }" 

        else

          message = "The test object (id: #{ @id }, type: #{ @type.inspect }, name: #{ @name.inspect }) has no child object with type or behaviour method with name #{ method_id.to_s.inspect }#{ attributes_string } on #{ @sut.id.inspect }" 

        end

        # raise exception
        raise MobyBase::TestObjectNotFoundError, message

      end

    end

    # helper function to retrieve child oblect(s), used by child and children methods
    def get_child_objects( attributes )

      ###############################################################################################################
      #
      #  NOTICE: Please do not add anything unnessecery to this method, it might cause a major performance impact
      #
            
      # for backwards compatibility
      if attributes.has_key?( :__logging )

        # for backward compatibility          
        if attributes[ :__logging ].kind_of?( String )
          
          warn "warning: deprecated variable type String for :__logging test object creation directive (expected TrueClass or FalseClass)"          

          attributes[ :__logging ] = attributes[ :__logging ].to_boolean 
          
        end
      
      end
            
      # store original hash
      creation_hash = attributes.clone

      dynamic_attributes = creation_hash.strip_dynamic_attributes!

      # raise exception if wrong value type given for ;__logging 
      dynamic_attributes[ :__logging ].check_type( 

        [ TrueClass, FalseClass ], 

        "wrong value type $1 for :__logging test object creation directive (expected $2)" 

      ) if dynamic_attributes.has_key?( :__logging )

      # disable logging if requested, remove pair from creation_hash
      $logger.push_enabled( dynamic_attributes[ :__logging ] || TDriver.logger.enabled )

      # check if the hash contains symbols as values and translate those into strings
      @sut.translate_values!( creation_hash, attributes[ :__fname ], attributes[ :__plurality ], attributes[ :__numerus ], attributes[ :__lengthvariant ] )

      begin

        # TODO: refactor me
        child_test_object = @test_object_factory.get_test_objects(

          # current object as parent, can be either TestObject or SUT
          :parent => self,
 
          # pass parent application
          :parent_application => @parent_application,
 
          # test object identification hash
          :object_attributes_hash => creation_hash, 

          # pass test object identification directives, e.g. :__index          
          :identification_directives => dynamic_attributes

        )

      rescue Exception => exception

        if exception.kind_of?( MobyBase::MultipleTestObjectsIdentifiedError )

          description = "Multiple child objects matched criteria."

        elsif exception.kind_of?( MobyBase::TestObjectNotFoundError )

          description = "The child object(s) could not be found."

        elsif exception.kind_of?( MobyBase::TestObjectNotVisibleError )

          description = "Parent test object no longer visible."

        else

          description = "Failed when trying to find child object(s)."

        end

        $logger.behaviour "FAIL;#{ description };#{ identity };#{ dynamic_attributes[ :__multiple_objects ] ? "children" : "child" };#{ attributes.inspect }"

        raise exception

      ensure

        # restore original logger state
        $logger.pop_enabled

      end

      # return child test object
      child_test_object

    end

    # == nodoc
    # Changes the status of the test object to inactive, also deactivating all children
    # Removes reference from @parent TestObject or SUT to this TestObject so that 
    # @parent.refresh does not refresh currrent TestObject
    #
    # Does nothing if TestObject is already deactivated
    # == returns 
    # ?
    def deactivate

      return if !@_active

      @_active = false

      # iterate through all test objects child test objects
      @child_object_cache.each_object{ | test_object |
      
        # deactivate test object
        #test_object.deactivate
 
        test_object.instance_exec{ deactivate }
              
      }

      # remove test objects from children objects cache
      @child_object_cache.remove_objects

      # remove from parent objects children objects cache
      @parent.instance_variable_get( :@child_object_cache ).remove_object( self )

    end

    # TODO: refactor logging_enabled 
    # try to reactivate test object if currently not active
    def reactivate_test_object( attributes )

      refresh_args = ( attributes[ :type ] == 'application' ? { :name => attributes[ :name ], :id => attributes[ :id ] } : { :id => get_application_id } )

      refresh( refresh_args )

      begin

        @parent.child( :type => @type, :id => @id )

      rescue MobyBase::TestObjectNotFoundError

        raise MobyBase::TestObjectNotVisibleError

      end

    end

    # Creates a string identifying this test object: sut, type, attributes used when created
    #
    # === returns
    # String:: String identifying this test object
    def identity

      "#{ @sut.id };#{ @type };#{ @creation_attributes.inspect }"

    end

    # TODO: document me
    # NOTE: this method should be called only internally, TestObject#attribute is end-user method that shouldn't be called inside framework
    def find_attribute( name )

      # store xml data to variable, due to xml_data is a function that returns result of xpath to sut.xml_data
      _xml_data = nil

      # note: tries count represents total number of tries
      MobyUtil::Retryable.while( :tries => 2, :interval => 0 ) { | attempt |

        begin
  
          begin

            # retrieve xml data, performs xpath to sut xml_data
            _xml_data = xml_data

          rescue MobyBase::TestObjectNotFoundError    

            # attributes used to refresh parent application
            if @creation_attributes[ :type ] == 'application'

              # use application name and id attributes
              refresh_args = { :name => @creation_attributes[ :name ], :id => @creation_attributes[ :id ] }

            else

              # test object if not type of application
              refresh_args = { :id => get_application_id }

            end

            #refresh( refresh_args )

            # lets refresh if attribute not found on first attempt
            @sut.refresh( 

              refresh_args, @test_object_factory.make_object_search_params( parent, @creation_attributes )

            )

            # retrieve updated xml data
            _xml_data = xml_data

          end

          # raise eception if xml data is empty or nil
          raise MobyBase::TestObjectNotInitializedError.new if _xml_data.nil? || _xml_data.to_s.empty?

          begin
          
            # retrieve attribute(s) from test object; never access ui state xml data directly from behaviour implementation
            @test_object_adapter.test_object_attribute( _xml_data, name )

          rescue MobyBase::AttributeNotFoundError
          
            raise MobyBase::AttributeNotFoundError, "Could not find attribute #{ name.inspect } for test object of type #{ @type.to_s }"

          end

        rescue MobyBase::AttributeNotFoundError

          # add attribute to attribute filter whitelist only once
          if ( attempt == 1 )

            # add to attribute filter 
            TDriver::AttributeFilter.add_attribute( name )

            # refresh test object ui state
            refresh

          end

          # raise exception and retry if attempts left
          raise

        end

      }

    end

    # this method will be automatically invoked after module is extended to target object
    def self.extended( target_object )

      target_object.instance_exec{ 
      
        # defaults
        @_application_id ||= nil

        @creation_attributes ||= nil

        @_active ||= true

        @parent_application ||= nil
        
      }

    end

  public

    # == deprecated
    # 0.8.x
    #
    # == description
    # This method is deprecated, please use TestObject#parent
    # This method is deprecated, please use [link="#GenericTestObject:parent"]TestObject#parent[/link] instead.
    #
    def parent_object

      # == description
      # Returns the actual test object that was used as the parent when this object instance was created. 
      # Userd to retrieve the parent object in the UI object hierarchy, 
      # see get_parent.
      #
      # == returns
      # TestObject:: test object that was used as parent when this object was created. Can also be of type SUT if sut was the parent (ie. application objects)
  
      warn_caller '$1:$2 warning: TestObject#parent_object is deprecated, please use TestObject#parent instead.'

      @parent

    end

    # == deprecated
    # 1.1.1
    #
    # == description
    # This method is deprecated, please use [link="#GenericTestObject:state_object"]TestObject#state_object[/link] instead.
    #
    def state

      warn_caller '$1:$2 warning: deprecated method TestObject#state; please use TestObject#state_object instead'

      state_object

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # TestObject 

end # MobyBehaviour
