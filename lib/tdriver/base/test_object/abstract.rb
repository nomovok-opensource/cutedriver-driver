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
			:sut, 		# SUT associated to test object
			:type, 		# test object type (from xml)
			:id, 		# test object id (from xml)
			:parent,	# parent test object
			:name, 		# test object name (from xml)
			:x_path		# xpath for test object, used when updating self with fresh ui dump
		)

		# Creation of a new TestObject requires a data object to be given to constructor
		# === params
		# factory:: TestObjectFactory used for creating test object for the sut this object is associated with
		# sut:: SUT object that this test object is associated with
		# xml_object:: REXML::Document object describing this test object
		# === returns
		# TestObject:: new TestObject instance
		# === raises
		def initialize( test_object_factory, sut, parent = nil, xml_object = nil )

			# Initializes a test object by assigning it a test object factory and a sut and storing xml data 
			# describing the object.
			@test_object_factory = test_object_factory
			@parent = parent
			@sut = sut

      p xml_object.class

			#self.xml_data = xml_object if xml_object
			method( :xml_data= ).call( xml_object ) if xml_object
			
		end

		# Function to verify is DATA of two TestObjects are the same, 
		# Defined in TestObject#== other_test_object
		# === param
		# other_test_object:: TestObject other, could be null
		# === returns
		# true:: if TestObjects have same DATA
		# false:: if TestObjects have different DATA
		# === raises
		# nothing
		def eql?( other_test_object )
			self == other_test_object
		end

		# Function to verify is DATA of two TestObjects are the same, 
		# return TRUE if other_test_object:
		#   instance of MobyBase::TestObject
		#   type's are equal
		#   id's are equal
		#   name's are equal
		# == param
		# other_test_object:: TestObject other, could be null
		# == returns
		# true:: if TestObjects have same DATA
		# false:: if TestObjects have different DATA
		# == raises
		# nothing
		def ==( other_test_object )

			#return false unless other_test_object.instance_of?( MobyBase::TestObject ) 
			#return false unless self.type == other_test_object.type
			#return false unless self.id == other_test_object.id
			#return false unless self.name == other_test_object.name
			#return true

			# optimized version			
			other_test_object.instance_of?( MobyBase::TestObject ) && ( @type == other_test_object.type ) && ( @id == other_test_object.id ) && (@name == other_test_object.name )

		end

		# Function to calculate HASH value for a TestObject
		# as required by, e.g. Set
		#
		# This is required, as eql? method is being overwritten.
		# === returns
		# Fixnum:: hash number representing current TestObject
		def hash

			#result = 17
			#result = result * 37 + self.id.to_i
			#result = result * 37 + type.hash
			#result = result * 37 + name.hash
			#return result

			# optimized version
			( ( ( 17 * 37 + @id.to_i ) * 37 + @type.hash ) * 37 + @name.hash )

		end

		# Function to support sorting TestObjects within an array.
		# Mostly for unit testing purposes, as Set is not ordered.
		# should not be used normally. Thus, not documented.
		def <=>( other )

			#self_type = self.type
			#other_type = other.type
			#return -1 if self_type < other_type
			#return 1  if self_type > other_type

			#self_name = self.name
			#other_name = other.name
			#return -1 if self_name < other_name
			#return 1  if self_name > other_name

			#self_id = self.id
			#other_id = other.id
			#return -1 if self_id < other_id
			#return 1  if self_id > other_id

			#0

			# optimized version
			( ( result = ( @type <=> other.type ) ) == 0 ? ( ( result = ( @name <=> other.name ) ) == 0 ? @id <=> other.id : result ) : result )  

		end

		# Function to be renamed, possibly refactored
		def xml_data=( xml_object )

=begin
			@name, 
			@x_path = 
				xml_object.attribute( 'name' ), 
				"%s/*//object[@type='%s' and @id='%s']" % [ 
					@parent.x_path, 
					@type = xml_object.attribute( 'type' ), 
					@id = xml_object.attribute( 'id' ) 
				]
=end

			@name, @x_path = xml_object.attribute( 'name' ), "#{ @parent.x_path }/*//object[@type='#{ @type = xml_object.attribute( 'type' ) }' and @id='#{ @id = xml_object.attribute( 'id' ) }']"

		end

    # TODO: document me
    def inspect

      "#<#{ self.class }:0x#{ ( "%x" % ( self.object_id.to_i << 1 ) )[ 3 .. -1 ] } @id=\"#{ @id }\" @name=\"#{ @name }\" @parent=#{ @parent.inspect } @sut=#{ @sut.inspect } @type=\"#{ @type }\" @x_path=\"#{ @x_path }\">"

    end

		# Returns a XML node representing this test object.
		#
		# === returns
		# LibXML::XML::Node:: XML representation of this test object
		# === raises
		# TestObjectNotFoundError:: The test object does not exist on the SUT any longer.
		def xml_data()

			#Kernel::raise MobyBase::TestObjectNotFoundError.new( 'The test object does not exist on the sut anymore.' ) if ( elements = @sut.xml_data.xpath( @x_path ) ).size.zero?

			#Kernel::raise MobyBase::TestObjectNotFoundError.new( "The test object with id: \"#{ @id.to_s }\", type: \"#{ @type.to_s }\" and name: \"#{ @name.to_s }\" does not exist on sut \"#{ @sut.id.to_s }\" anymore" ) if ( elements = @sut.xml_data.xpath( @x_path ) ).size.zero?

			Kernel::raise MobyBase::TestObjectNotFoundError.new( 'The test object (id: "%s", type: "%s", name: "%s") does not exist on sut (%s) anymore' % [ @id, @type, @name, @sut.id ]  ) if ( elements = @sut.xml_data.xpath( @x_path ) ).size.zero?

			elements.first

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # TestObject 

end # MobyBase
