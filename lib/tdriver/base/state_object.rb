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

		#include MobyBehaviour::TestObjectComposition
		include MobyBehaviour::ObjectComposition

		# The test object factory is needed for populating child object accessor methods
		#@test_object_factory

		attr_accessor :parent

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

			elsif xml_source.kind_of?(String)

				xml_element = MobyUtil::XML.parse_string(xml_source).root

			else

				Kernel::raise ArgumentError.new("The XML source must be a String or MobyUtil::XML::Element, it was of type '#{ xml_source.class.to_s }'.")

			end

			@parent = nil
			add_parent( parent ) unless parent.nil?

			self.xml_data= xml_element
			@_child_objects = Set.new

			# Create accessor methods for any child state objects.
			TestObjectFactory.instance.create_child_accessors!( self )

		end

		# Tries to use the missing method id as a child object type and find an object based on it
		def method_missing( method_id, *method_arguments )

			hash_rule = method_arguments.first

			# method mapping/aliases
			case method_id

				when :Button;	
					method_id = [ :Button, :QToolButton, :DuiButton, :HbPushButton, :softkey ]

				when :List;	
					method_id = [ :QList, :HbListWidgetView, :DuiList ]

			end

			hash_rule = Hash.new unless hash_rule.kind_of? Hash
			hash_rule[ :type ] = method_id 

			begin

				return child( hash_rule )

			rescue MobyBase::TestObjectNotFoundError, MobyBase::TestObjectNotVisibleError

				hash_rule.delete(:type)

				raise MobyBase::TestObjectNotFoundError.new(
					"The state object with id: \"#{ self.id.to_s }\", type: \"#{ self.type.to_s }\" and name: \"#{ self.name.to_s }\" has no child object of type \"#{ method_id.inspect.to_s }\"" << 
					( hash_rule.empty? ? "" : " attributes: #{ hash_rule.inspect },")) 
			end

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
		def == (other_state_object)
			return false unless other_state_object.instance_of?( MobyBase::StateObject ) 
			return false unless self.type == other_state_object.type
			return false unless self.id == other_state_object.id
			return false unless self.name == other_state_object.name
			return true
		end


		# Function to return type of the state object
		# === returns
		# type:: String value of the type
		def type()
			@type
		end

		# Function to return name of the state object
		# === returns
		# name String value of the name
		def name()
			@name
		end

		# Function to return id of the state object
		# === returns
		# id String value of the id
		def id()
			@object_id
		end

		# Sets the XML content of this state object. Also sets identification attributes based
		# on the contents of the XML.
		#
		# === params
		# xml_object:: MobyUtil::XML::Element. State as XML.
		def xml_data=( xml_object ) 
			@_xml_data = xml_object
			@name = xml_object.attribute( 'name' )
			@type = xml_object.attribute( 'type' )
			@object_id = xml_object.attribute( 'id' )
		end

		# Returns a XML element representing this state object.
		#
		# === returns
		# MobyUtil::XML::Element:: XML representation of this state object 
		def xml_data()
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

			# store xml_data to temp. variable
			_xml_data = @_xml_data

			Kernel::raise ArgumentError.new( "Wrong argument type %s for attribute argument (expected String)" % name.class ) unless name.class == String

			Kernel::raise MobyBase::AttributeNotFoundError.new("Could not find attribute '#{ name.to_s }' for state object of type '#{ type.to_s }'.") if ( 
				elements = _xml_data.xpath(
					"attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ name.to_s.downcase }']"
				) 
			).size == 0 

			elements.first.content.strip

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

			identified_object_xml = MobyBase::TestObjectIdentificator.new( attributes ).find_object_data( @_xml_data )

			child_object = StateObject.new( identified_object_xml, self )

			# return already existing child StateObject so that there is references to only one StateObject
			@_child_objects.each do | _child | 
				return _child if _child.eql? child_object
			end

			add_child( child_object ) 
			return child_object

		end

		def inspect 

			"#{ self.to_s }\nName: #{ self.name.to_s } Type: #{ self.type.to_s } Id: #{ self.id.to_s }"

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end # StateObject 

end # MobyBase
