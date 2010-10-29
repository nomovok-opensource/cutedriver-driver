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

    # === description
    # Determines if the current test object is of type 'application'
    # === returns
    # TrueClass:: 
    # FalseClass:: 
    #  == example
    # @test_app = @sut.run(:name => 'testapp') # launches testapp    
    # isApplication = @test_app.application?
    def application?

      @type == 'application'

    end

    # == description
    # Return all test object attributes
    # === returns
    # Hash:: Test object attributes
    # == example
    # @test_app = @sut.run(:name => 'testapp') # launches testapp 
    # attributes_hash = @test_app.Triangle( :name => 'Triangle1' ).attributes # retrieve all attribute for triangle object
    def attributes

      # return hash of test object attributes
      Hash[ xml_data.xpath( 'attributes/attribute' ).collect{ | test_object | [ test_object.attribute( 'name' ), test_object.content ] } ]

    end

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

      @_child_object_cache.each_value{ | test_object | 

        # deactivate test object
        test_object.deactivate  

      }

      @_child_object_cache.clear

      @parent.remove_child( self )

    end

    # == description
    # Function returns a attribute of test object 
    # == params
    # name:: String definig the name of the attribute to get
    # == returns
    # String:: Value of the attribute as a string
    # == exceptions
    # TestObjectNotInitializedError:: if the test object xml data has not been initialized
    # AttributeNotFoundError:: if the requested attribute can not be found in the xml data of the object
    # == example
    # @test_app = @sut.run(:name => 'testapp') # launches testapp 
    # puts @test_app.Triangle( :name => 'Triangle1' ).attribute('color') # prints color of triangle object
    def attribute( name )
	  
      # note: count of tries represents total number of tries
      MobyUtil::Retryable.while( :tries => 2, :interval => 0 ) { | attempt |

        begin
  
          # find attribute from xml
          find_attribute( name )

        rescue MobyBase::AttributeNotFoundError

          # do following actions only once
          if ( attempt == 1 )

            # add to dynamic attribute filter once
            MobyUtil::DynamicAttributeFilter.instance.add_attribute( name )

            # refresh ui state
            refresh( :id => get_application_id )

          end

          # raise exception and retry if attempts left
          raise

        end

      }

    end
		
    # == description
    # Returns the parent test object for the current object in question, according to the UI object hierarchy. For getting the test object that was actually used 
    # as the parent when the test object instance was created, see parent_object.
    # == returns
    # TestObject:: test object that is parent of this test object, self if no parent (ie. application objects)
    # == example
    # @app = @sut.run(:name => 'testapp') # launches testapp 
    # parent_test_object = @app.Node( :name => 'Node1' ).get_parent() #get parent for some test object
    def get_parent()

      return self if application?

	  @sut.refresh if disable_optimizer

      #find parent id
      #element_set = @sut.xml_data.xpath( "//object/objects/object[@id='%s']/../.." % @id )
      element_set = @sut.xml_data.xpath( "//object/objects/object[@id='#{ @id }']/../.." )

	  kid = nil 	  
	  if( element_set == nil or element_set.size == 0 )
		kid = self 
	  else
		element = element_set.first

		#if app set look for the item under the app to make sure app id is available

		if self.get_application_id && element.attribute( "type" ) != 'application'

		  kid = @sut.child( 

						   :id => get_application_id, 
						   :type => 'application' 

						   ).child( 

								   :id => element.attribute( "id" ), 
								   :name => element.attribute( "name" ), 
								   :type => element.attribute( "type" ),
								   :__index => 0 # there was a case when the same parent was included twice in the ui dump

								   )

		else

		  kid = @sut.child( 
						   :id => element.attribute( "id" ), 
						   :name => element.attribute( "name" ), 
						   :type => element.attribute( "type" ) 
						   )

		end
	  end
	  enable_optimizer
	  kid
    end
    
    # == nodoc
    # Updates this test object to match the data in the provided xml document
    # Propagates updating to all child TestObjects
    # If TestObject is not identified, then current TO is deactivated, as is all the Child objects, as defined in TestObject#deactivate.
    # === params
    # xml_document:: LibXML::XML::Node describing the new state of this test object
    # === returns 
    # ?
    # === raises
    # nothing
    def update( xml_document )

      begin

        if !( _xml_data = MobyBase::TestObjectIdentificator.new( :type => @type, :id => @id, :name => @name ).find_object_data( xml_document ) ).eql?( xml_data )

          @_child_objects.each { | test_object | test_object.update( ( xml_data = _xml_data ) ) }

        end

      rescue MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError

        deactivate

      end

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

	    object_search_params = @test_object_factory.make_object_search_params(@creation_attributes)
	    search_params = @test_object_factory.get_parent_params(parent)
	    search_params.push(object_search_params)	    
      @sut.refresh( refresh_args, search_params )

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
    def force_refresh( refresh_args = {} )

      refresh(refresh_args)

    end

    # == description
    # Function for finding out the application this test ojbect
    # == returns
    #TestObject:: Application test object that the test object belongs to, or nil, if no parent of type application can be found.
    # == example
    # parent_app = @app.Node( :name => 'Node1' ).get_application() #get application for some test object, this should return @app.
    def get_application

      return self if application?

      test_object = @parent

      while test_object

        return test_object if ( test_object.type == 'application' )

        test_object = test_object.parent

      end

      # return application object or nil if no parent found
      # Does is make sense to return nil - should  n't all test objects belong to an application? Maybe throw exception if application not found

      return @sut.child( :type => 'application' ) rescue nil

    end

    # == description
    # Function for finding out the application id for this test object
    # == returns
    # String:: representing the id of the application test object that this test object belongs to.
    # == example
    # puts @app.Node( :name => 'Node1' ).get_application_id() #print the application id, this should print @app.id
    def get_application_id

      return @_application_id if @_application_id
      #What about the case when get_application returns nil? This line will throw an exception in that case.
      get_application.id

    end

    # == nodoc
    def set_application_id( application_id )

      @_application_id = application_id

     end

    # == description
    # Returns a StateObject containing the current state of this test object as XML.
    # The state object is static and thus is not refreshed or synchronized etc.
    # == returns
    # StateObject:: State of this test object
    # == exceptions
    # ArgumentError
    # description: If the xml source for the object cannot be read
    # == example
    # app_state = @sut.application( :name => "calculator" ).state #get the state object for the app
    # button_state = app_state.Button( :text => "Backspace" ) #get the state for test object button
    # button_text = button_state.attribute( "text" ) #get attribute text from the button state object
    def state

      MobyBase::StateObject.new( xml_data, self )

    end

	  # Function for translating all symbol values into strings using sut's translate method
	  # Goes through all items in a hash and if a value is symbol then uses that symbol as a logical
	  # name and tries to find a translation for that.
	  # === params
	  # hash:: Hash containing key, value pairs. The parameter will get modified if symbols are found from values
	  # === raises
	  # LanguageNotFoundError:: In case of language is not found
	  # LogicalNameNotFoundError:: In case of logical name is not found for current language
	  # MySqlConnectError:: In case problems with the db connectivity
	  def translate!( hash, file_name = nil, plurality = nil, numerus = nil, lengthvariant = nil )

      hash.each_pair do | _key, _value |

        next if [ :name, :type, :id ].include?( _key )

        hash[ _key ] = sut.translate( _value, file_name, plurality, numerus, lengthvariant ) if _value.kind_of?( Symbol )  

      end if !hash.nil?

    end

    # == description
    # Creates a test object for a child object of this test object. Caller test object will be result (child) object's parent object.\n
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
    #  description: raised if agument is not a Hash
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
      raise TypeError.new( 'Unexpected argument type (%s) for attributes, expecting %s' % [ attributes.class, "Hash" ] ) unless attributes.kind_of?( Hash ) 

      # retrieve child object
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
      raise TypeError.new( 'Unexpected argument type (%s) for attributes, expecting %s' % [ attributes.class, "Hash" ] ) unless attributes.kind_of?( Hash ) 

      # respect the original attributes variable value
      creation_attributes = attributes.clone

      # If empty or only special attributes then add :type => "any" to search all
      creation_attributes.merge!( :type => "any" ) if creation_attributes.select{ | key, value | key.to_s !~ /^__/ ? true : false }.empty?

      # children method specific settings
      creation_attributes.merge!( :__multiple_objects => true, :__find_all_children => find_all_children )


	  disable_optimizer
      # retrieve child objects
      kids = get_child_objects( creation_attributes )
	  enable_optimizer


	  kids

    end

  private

	def disable_optimizer
	  #disable optimizer for this call since it will not work
	  @_enable_optimizer = false
	  if MobyUtil::Parameter[ @sut.id ][ :use_find_object, 'false' ] == 'true' and @sut.methods.include?('find_object')
		MobyUtil::Parameter[ @sut.id ][ :use_find_object] = 'false'
		@_enable_optimizer = true
	  end	  
	  @_enable_optimizer
	end

	def enable_optimizer
	  MobyUtil::Parameter[ @sut.id ][ :use_find_object] = 'true' if @_enable_optimizer
	  @_enable_optimizer = false
	end

    # Tries to use the missing method id as a child object type and find an object based on it
    def method_missing( method_id, *method_arguments )

      # method mapping/aliases - this should be configured in xml file
      #case method_id
      #  when :Button;  method_id = [ :Button, :QToolButton, :DuiButton, :HbPushButton, :softkey ]
      #  when :List;  method_id = [ :QList, :HbListWidgetView, :DuiList ]
      #end

      hash_rule = ( method_arguments.first.kind_of?( Hash ) ? method_arguments.first : {} ).merge( :type => method_id )

      begin

        child( hash_rule )

      rescue MobyBase::TestObjectNotFoundError, MobyBase::TestObjectNotVisibleError

        #hash_rule.delete( :type )

        Kernel::raise MobyBase::TestObjectNotFoundError.new(
          'The test object (id: "%s", type: "%s", name: "%s") has no child object with type or behaviour method with name "%s" (%s) on sut "%s".' % 
          [ @id, @type, @name, method_id.inspect, ( hash_rule.empty? ? "" : "attributes: #{ hash_rule.inspect }" ), @sut.id ]
        )

      end

    end

    # TODO: refactor logging_enabled 
    # try to reactivate test object if currently not active
    def reactivate_test_object( attributes )

      refresh_args = ( attributes[ :type ] == 'application' ? { :name => attributes[ :name ], :id => attributes[ :id ] } : { :id => get_application_id } )

      refresh( refresh_args)

      begin

        @parent.child( :type => @type, :id => @id )

      rescue MobyBase::TestObjectNotFoundError => exception

        Kernel::raise MobyBase::TestObjectNotVisibleError

      end

    end

    # Strip dynamic attributes (such as :__timeout, :__logging) from hash and return those as hash
    # == returns
    # Hash:: Hash of dynamic attributes
    def strip_dynamic_attributes!( attributes, exceptions = [] )

      Hash[ attributes.select{ | key, value | 

        if /^__/.match( key.to_s ) and !exceptions.include?( key )

          attributes.delete( key )

          true

        else

          false

        end

      }]

    end

    def get_cached_test_object!( object )

      object_hash = object.hash

      if @_child_object_cache.has_key?( object_hash ) 

        object = @_child_object_cache[ object_hash ]

        true

      else

        false

      end

    end

    def get_child_objects( attributes )

      # create copy of attributes hash
      creation_data = attributes.clone

      # strip all dynamic attributes such as :__timeout, :__logging etc.
      dynamic_attributes = strip_dynamic_attributes!( creation_data )

      # store and set logger state if given, use default value if none given
      TDriver.logger.push_enabled( MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__logging ], TDriver.logger.enabled ) )

      # determine if multiple matches is allowed, default value is false
      multiple_objects = MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__multiple_objects ], false )

      find_all_children = MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__find_all_children ], true )

	  # check if the hash contains symbols as values and translate those into strings
	  file_name = dynamic_attributes[ :__fname ]
	  plurality = dynamic_attributes[ :__plurality ]
	  numerus = dynamic_attributes[ :__numerus ]
	  lengthvariant = dynamic_attributes[ :__lengthvariant ]
	  translate!( creation_data, file_name, plurality, numerus, lengthvariant )

      # use custom timeout if defined
      timeout = ( dynamic_attributes[ :__timeout ] || @test_object_factory.timeout ).to_i

      # determine which application to refresh
      application_id_hash = ( creation_data[ :type ] == 'application' ? { :name => creation_data[ :name ], :id => creation_data[ :id ] } : { :id => get_application_id } )

      # add symbols to dynamic attributes list -- to avoid IRB bug
      MobyUtil::DynamicAttributeFilter.instance.add_attributes( creation_data.keys )

      begin

        # try to reactivate test object if currently not active
        reactivate_test_object( creation_data ) unless @_active

        # retrieve test objects from xml
        child_objects = @test_object_factory.make_child_objects( 

          :attributes => creation_data,
          :dynamic_attributes => dynamic_attributes, 

          :parent => self,
          :sut => @sut,
          :application => application_id_hash,

          :timeout => timeout,
          :multiple_objects => multiple_objects,
          :find_all_children => find_all_children

        )

        # Type information is stored in a separate member, not in the Hash
        #creation_data.delete( :type )

        child_objects.each do | child_object |

          # use cached test object if once already retrieved
          get_cached_test_object!( child_object ).tap{ | found_in_cache |

            # Store/update the attributes that were used to create the child object.
            child_object.creation_attributes = creation_data

            # add child to objects cache 
            add_child( child_object ) unless found_in_cache

          }

        end

        # return test object(s)
        multiple_objects ? child_objects : child_objects.first

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

        TDriver.logger.behaviour(

          "%s;%s;%s;%s;%s" % [ "FAIL", description, identity, multiple_objects ? "children" : "child", creation_data.inspect ]

        )

        Kernel::raise exception

      ensure

        # restore logger state
        MobyUtil::Logger.instance.pop_enabled

      end

    end

    # Creates a string identifying this test object: sut, type, attributes used when created
    #
    # === returns
    # String:: String identifying this test object
    def identity

      #"%s;%s;%s" % [ @sut.id, @type, @creation_attributes.inspect ]
      "#{ @sut.id };#{ @type };#{ @creation_attributes.inspect }"

    end

    def find_attribute( name )

      # store xml data to variable, due to xml_data is a function that returns result of xpath to sut.xml_data
	  _xml_data = nil
	  begin
		_xml_data = xml_data
	  rescue MobyBase::TestObjectNotFoundError		
		#lets refresh if not found initially
		refresh_args = ( @creation_attributes[ :type ] == 'application' ? { :name => @creation_attributes[ :name ], :id => @creation_attributes[ :id ] } : { :id => get_application_id } )
		
		refresh( refresh_args)
		_xml_data = xml_data
	  end

      # convert name to string if variable type is symbol
      name = name.to_s if name.kind_of?( Symbol )

      # raise exception if attribute name variable type is other than string
      Kernel::raise ArgumentError.new( "Wrong argument type %s for attribute argument (expected String)" % name.class ) unless name.kind_of?( String )

      # raise eception if xml data is empty or nil
      Kernel::raise MobyBase::TestObjectNotInitializedError.new if _xml_data.nil? || _xml_data.to_s.empty?

      # retrieve attribute(s) from xml
      #nodeset = _xml_data.xpath( "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='%s']" % name.downcase )
      nodeset = _xml_data.xpath( "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ name.downcase }']" ) 

      # raise exception if no such attribute found
      Kernel::raise MobyBase::AttributeNotFoundError.new( "Could not find attribute '%s' for test object of type '%s'." % [ name, type ] ) if nodeset.empty? 

      # Need to disable this for now #Kernel::raise MobyBase::MultipleAttributesFoundError.new( "Multiple attributes found with name '%s'" % name ) if nodeset.count > 1

      # return found attribute
      nodeset.first.content.strip

    end

    # this method will be automatically invoked after module is extended to sut object  
    def self.extended( target_object )

      target_object.instance_exec{

        initialize_settings

      }

    end

    def initialize_settings

      # defaults
      @_application_id = nil
      @creation_attributes = nil

      @_child_object_cache = {}

      activate

    end

    # == description
    # Returns the actual test object that was used as the parent when this object instance was created. For getting the parent object in the UI object hierarchy, 
    # see get_parent.
    #
    # == returns
    # TestObject:: test object that was used as parent when this object was created. Can also be of type SUT if sut was the parent (ie. application objects)

  public

    # This method is deprecated, please use [link="#GenericTestObject:parent"]TestObject#parent[/link] instead.
    # == deprecated
    # 0.8.x
    #
    # == description
    # This method is deprecated, please use TestObject#parent
    #
    def parent_object()

      $stderr.puts "warning: TestObject#parent_object is deprecated, please use TestObject#parent instead."      

      @parent

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObject 

end # MobyBehaviour
