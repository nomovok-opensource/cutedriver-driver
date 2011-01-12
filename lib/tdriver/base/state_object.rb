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

  # Static representation of the state of a TestObject or SUT. 
  # StateObject are not refreshed or synchronize etc.
  class StateObject

    include MobyBehaviour::ObjectComposition

    # The test object factory is needed for populating child object accessor methods
    #@test_object_factory

    # == description
    # attr_accessor
    #
    # == returns
    # Test Object
    #  description: test object that was used as parent when this object was created. Can also be of type SUT if sut was the parent (ie. application objects)
    #  example: "@sut"
    attr_accessor :parent

    # TODO: document me
    attr_reader :type, :name, :id

    # Creates a new StateObject from XML source data.
    #
    # === params
    # xml_source:: MobyUtil::XML::Element or String. Contains the root element of this state.
    # parent:: TestObject, SUT or StateObject. Parent of this state object. Must be of type TestObjectComposition. 
    # === returns
    # StateObject:: New StateObject
    def initialize( xml_source, parent = nil )

      xml_element = nil

      if xml_source.kind_of?( MobyUtil::XML::Element )

        xml_element = xml_source

      elsif xml_source.kind_of?( String )

        xml_element = MobyUtil::XML.parse_string(xml_source).root

      else

        Kernel::raise ArgumentError, "The XML source must be a String or MobyUtil::XML::Element, it was of type '#{ xml_source.class.to_s }'"

      end

      @parent = parent 

      method(:xml_data=).call( xml_element )

      @child_object_cache = TDriver::TestObjectCache.new

      # Create accessor methods for any child state objects.
      TDriver::TestObjectAdapter.create_child_accessors!( xml_element, self )

    end

    # Tries to use the missing method id as a child object type and find an object based on it
    def method_missing( method_id, *method_arguments )

      rules_hash = method_arguments.first

      rules_hash = Hash.new unless rules_hash.kind_of? Hash

      rules_hash[ :type ] = method_id 

      begin

        return child( rules_hash )

      rescue MobyBase::TestObjectNotFoundError, MobyBase::TestObjectNotVisibleError

        rules_hash_clone = rules_hash.clone
        
        rules_hash_clone.delete( :type )

        # string representation of used rule hash
        search_attributes_string = rules_hash_clone.collect{ | key, value | ":#{ key } => #{ value.inspect }" }.join( ', ')

        # construct literal representation of object identifiers        
        object_attributes = []        
        object_attributes << "id: #{ @id }" if @id
        object_attributes << "type: #{ @type.inspect }" if @type
        object_attributes << "name: #{ @name.inspect }" if @name
        
        if search_attributes_string.empty?
        
          # do not show any attribute details if none given                
          search_attributes_string = ""
          
        else
  
          # show used attributes      
          search_attributes_string = " (attributes #{ search_attributes_string })"

        end

        # raise exception
        Kernel::raise MobyBase::TestObjectNotFoundError.new(
          "The state object (#{ object_attributes.join(", ") }) has no child object with type or behaviour method with name #{ method_id.to_s.inspect }#{ search_attributes_string }" 
        )

      end

    end

    # Verifies that another StateObject contains the same data as this object.
    # type, id and name must match.
    #
    # == param
    # other_state_object:: StateObject that this object is compared to.
    # == returns
    # true:: The other StateObject contains the same data as this one.
    # false:: The other StateObject does notcontain the same data as this one.
    # == raises
    # nothing
    def ==( test_object )

      # optimized version
      test_object.instance_of?( MobyBase::StateObject ) && ( @type == test_object.type ) && ( @id == test_object.id ) && ( @name == test_object.name )

    end

    # Check to StateObject objects for equality (ie. contents, not if they are the same object).
    # === param
    # other_state_object:: StateObject this object is compared to.
    # === returns
    # true:: other_state_object is equal to this StateObject.
    # false:: other_state_object is not equal to this StateObject.
    def eql? (other_state_object)

      self == other_state_object

    end


    # Sets the XML content of this state object. Also sets identification attributes based
    # on the contents of the XML.
    #
    # === params
    # xml_object:: MobyUtil::XML::Element. State as XML.
    def xml_data=( xml_object )
     
      @_xml_data = xml_object
            
      unused_xpath, @name, @type, @id = TDriver::TestObjectAdapter.get_test_object_identifiers( xml_object )
      
    end
    

    # Returns a XML element representing this state object.
    #
    # === returns
    # MobyUtil::XML::Element:: XML representation of this state object 
    def xml_data

      @_xml_data

    end

    # Function provides access to parameters of the state object 
    # === params
    # name:: String defining the name of the attribute to get
    # === returns
    # String:: Value of the attribute as a string
    # === raises
    # ArgumentError:: name is not a String.
    # AttributeNotFoundError:: if the requested attribute can not be found in the xml data of the object
    def attribute( name )

      # check argument variable type
      name.check_type( String, "wrong argument type $1 for attribute name (expected $2)" )

      begin

        # retrieve attribute(s) from test object; never access ui state xml data directly from behaviour implementation
        TDriver::TestObjectAdapter.test_object_attribute( @_xml_data, name.to_s )

      rescue MobyBase::AttributeNotFoundError
      
        raise MobyBase::AttributeNotFoundError, "Could not find attribute '#{ name.to_s }' for state object of type '#{ type.to_s }'"
        
      end

    end

    def get_cached_test_object!( object )

      if @child_object_cache.has_object?( object ) 

        object = @child_object_cache[ object ]

        true

      else

        false

      end

    end

    # Creates a state object for a child object of this state object
    # Associates child object as current object's child.
    # and associates self as child object's parent.
    #
    # NOTE:
    # Subsequent calls to #child always returns reference to same child
    # === params
    # attributes:: Hash object holding information for identifying which child to create, eg. :type => :slider
    # === returns
    # StateObject:: new child state object or reference to existing child
    def child( attributes )

      get_objects( attributes, false )

    end

    # TODO: document me
    def children( attributes )

      get_objects( attributes, true )
    
    end
    
    # TODO: document me
    def inspect

      "#<#{ self.class }:0x#{ ( "%x" % ( self.object_id.to_i << 1 ) )[ 3 .. -1 ] } @id=#{ @id.inspect } @type=\"#{ @type }\" @name=\"#{ @name }\">"

    end

  private
  
    def get_objects( attributes, multiple_objects )
    
      rules = attributes.clone

      # strip dynamic attributes from rules hash
      dynamic_attributes = rules.strip_dynamic_attributes!

      # retrieve application object from sut.xml_data
      matches, unused_rule = TDriver::TestObjectAdapter.get_objects( @_xml_data, rules, true )

      if matches.count == 0

        # raise exception if no matches found
        raise MobyBase::TestObjectNotFoundError 

      elsif matches.count > 1 and multiple_objects == false and dynamic_attributes.has_key?( :__index ) == false

        # raise exception if multiple maches found      
        raise MobyBase::MultipleTestObjectsIdentifiedError, "Multiple objects found with attributes #{ attributes.inspect }"

      end

      # fetch matches, use index if given
      matches = [ matches[ dynamic_attributes[ :__index ] || 0 ] ] unless multiple_objects
      
      # create state objects
      matches = matches.collect{ | object_xml |
      
        result = StateObject.new( object_xml, self )
        
        # use cached state object if once already retrieved
        get_cached_test_object!( result ).tap{ | found_in_cache |

          # add child to objects cache 
          @child_object_cache.add_object( result ) unless found_in_cache

        }
      
        # pass result object to array
        result
                
      }

      # return results      
      multiple_objects ? matches : matches.first
        
    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # StateObject 

end # MobyBase
