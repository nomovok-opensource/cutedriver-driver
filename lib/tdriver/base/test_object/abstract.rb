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

  class TestObject

    attr_reader(
      :sut,     # SUT associated to test object
      :type,    # test object type (from xml)
      :id,      # test object id (from xml)
      :parent,  # parent test object
      :name,    # test object name (from xml)
      :x_path   # xpath for test object, used when updating self with fresh ui dump
    )

    # Creation of a new TestObject requires options hash to be given to constructor.
    # === params
    # options:: Hash containing xml object describing the object and all other required configuration values e.g. test object factory, -adapter etc.
    # === returns
    # TestObject:: new TestObject instance
    # === raises
    def initialize( options )

      # verify that given argument is type of hash    
      options.check_type Hash, 'wrong argument type $1 for TestObject#new (expected $2)'

      # verify that required keys is found from options hash and initialize the test object with these values
      @sut                  = options.require_key :sut

      @test_object_factory  = options.require_key :test_object_factory
      @test_object_adapter  = options.require_key :test_object_adapter
      @creation_attributes  = options.require_key :creation_attributes

      # verify that parent object and parent application is given in options hash
      @parent               = options.require_key :parent
      @parent_application   = options.require_key :parent_application

      # store sut id
      @sut_id               = @sut.instance_variable_get :@id

      # initialize cache object 
      @child_object_cache   = TDriver::TestObjectCache.new

      # empty test object behaviours list
      @object_behaviours    = []

      # apply xml object if given; test object type, id and name are retrieved from the xml 
      __send__ :xml_data=, options[ :xml_object ] if options.has_key?( :xml_object )
 
    end

    # Function to verify is DATA of two TestObjects are the same, 
    # Defined in TestObject#== test_object
    # === param
    # test_object:: TestObject other, could be null
    # === returns
    # true:: if TestObjects have same DATA
    # false:: if TestObjects have different DATA
    # === raises
    # nothing
    def eql?( test_object )

      __send__ :==, test_object

    end

    # Function to verify is DATA of two TestObjects are the same, 
    # return TRUE if test_object:
    #   instance of MobyBase::TestObject
    #   type's are equal
    #   id's are equal
    #   name's are equal
    # == param
    # test_object:: TestObject other, could be null
    # == returns
    # true:: if TestObjects have same DATA
    # false:: if TestObjects have different DATA
    # == raises
    # nothing
    def ==( test_object )

      #return false unless test_object.instance_of?( MobyBase::TestObject ) 
      #return false unless @type == test_object.type
      #return false unless @id == test_object.id
      #return false unless @name == test_object.name
      #return true

      # optimized version
      test_object.instance_of?( MobyBase::TestObject ) && ( @type == test_object.type ) && ( @id == test_object.id ) && ( @name == test_object.name )

    end

    # Function to calculate HASH value for a TestObject
    #
    # This is required, as eql? method is being overwritten.
    # === returns
    # Fixnum:: hash number representing current TestObject
    def hash

      #result = 17
      #result = result * 37 + @id.to_i
      #result = result * 37 + @hash
      #result = result * 37 + @hash
      #return result

      # optimized version
      #( ( ( 17 * 37 + @id.to_i ) * 37 + @type.hash ) * 37 + @name.hash )

      @test_object_adapter.test_object_hash( @id.to_i, @type, @name )

    end

    # Function to support sorting TestObjects within an array.
    # Mostly for unit testing purposes, as Set is not ordered.
    # should not be used normally. Thus, not documented.
    def <=>( test_object )

      #self_type = @type
      #other_type = test_object.type
      #return -1 if self_type < other_type
      #return 1  if self_type > other_type

      #self_name = @name
      #other_name = test_object.name
      #return -1 if self_name < other_name
      #return 1  if self_name > other_name

      #self_id = @id
      #other_id = test_object.id
      #return -1 if self_id < other_id
      #return 1  if self_id > other_id

      #0

      # optimized version
      ( ( result = ( @type <=> test_object.type ) ) == 0 ? ( ( result = ( @name <=> test_object.name ) ) == 0 ? @id <=> test_object.id : result ) : result )  

    end

    # Function to be renamed, possibly refactored
    def xml_data=( xml_object )

      @x_path, @name, @type, @id, @env = @test_object_adapter.get_test_object_identifiers( xml_object, self )

    end

    # Returns a XML node representing this test object.
    #
    # === returns
    # MobyUtil::XML::Element:: XML representation of this test object
    # === raises
    # TestObjectNotFoundError:: The test object does not exist on the SUT any longer.
    def xml_data

      begin
      
        @test_object_adapter.get_xml_element_for_test_object( self )

      rescue MobyBase::TestObjectNotFoundError
      
        Kernel::raise MobyBase::TestObjectNotFoundError.new( 

          "The test object (id: #{ @id.inspect }, type: #{ @type.inspect }, name: #{ @name.inspect }) does not exist on #{ @sut.id.inspect } anymore" 
        
        )
      
      end

    end

    # TODO: document me
    def inspect

      "#<#{ self.class }:0x#{ ( "%x" % ( self.object_id.to_i << 1 ) )[ 3 .. -1 ] } @id=\"#{ @id }\" @name=\"#{ @name }\" @parent=#{ @parent.inspect } @sut=#{ @sut.inspect } @type=\"#{ @type }\" @x_path=\"#{ @x_path }\">"

    end
    
    private
    
    def sut_parameters
      
      $parameters[ @sut_id ]
    
    end
    
    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # TestObject 

end # MobyBase
