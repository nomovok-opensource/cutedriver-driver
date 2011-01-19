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

	# Class to represent TestObjectIdentificator
	# TestObjectIdentificator identifies TestObject representation from a TasMessage xml document.
	class TestObjectIdentificator

		attr_accessor :dynamic_attributes

		@@required_attributes = [ :type, :id, :name, :parent ]

		# special cases: allow partial match when value of :type and attribute name matches
		@@partial_match_allowed = [ [ :list_item, :Text ], [ 'list_item', :Text ], [ :application, :FullName ], ['application', :FullName ] ]

		# Creating new TestObjectIdentificator gets one argument as a Hash
		# The hash contains rules with which xml fragments are identified within the scope.
		# The scope can be either whole UI dump, or a TestObject containing child objects
		#
		# Usage: @test_object_identificator.new (:type => :softkey, :Text => Options)
		#  ==> tries to find 'softkey' TestObject, which has an attribute 'Text' with value 'Options' 
		# Usage: @test_object_identificator.new (:type => :list)
		#  ==> tries to identify the only list currently seen in the scope
		#
		# == params
		# hash_rules:: hash containing rules to identify.
		# NOTE: the hash_rule MUST contain either mapping from 
		# :type => <some_type> OR
		# :id => <some id>
		# == return
		# TestObjectIdentificator:: set with specific rules
		# == raises
		# ArgumentError:: if hash_rules does not contain either :type or :id
		def initialize( hash_rules = {} )

			# Relaxing conditoins of search, no need for mandatory :name, :type or :id rule
			#Kernel::raise ArgumentError.new('Cannot create a TestObjectIdentifier without :name, :type or :id rule') unless ( hash_rules.has_key?( :type ) or hash_rules.has_key?( :id ) or hash_rules.has_key?( :name ) )

			# ensure that each attribute keys used for object identification are type of Symbol
			@_attributes_used_to_identify_object = Hash[ hash_rules.collect{ | key, value | [ key.to_sym, value ] } ]

			@dynamic_attributes = Hash[ hash_rules.select{ | key, value | key.to_s =~ /^__/ } ]

			@insignificant_attributes = @@required_attributes + [ :__index ] + [ :__xy_sorting ] + [ :__fname ] + [ :__plurality ] + [ :__numerus ] + [ :__lengthvariant ]

		end

		# TODO: Documentation
		def find_objects( from_xml_element, find_all_children )

			[ from_xml_element.xpath( rule = xpath_to_identify( find_all_children ) ), rule ]

		end

		# getter to return the rules used in identification
		# == returns
		# Hash:: Hash object containing the rules
		def get_identification_rules

			@_attributes_used_to_identify_object

		end

		# Sort XML nodeset of test objects with layout direction
		def sort_elements_by_xy_layout!( nodeset, layout_direction = "LeftToRight" )

			attribute_pattern = "./attributes/attribute[@name='%s']/value/text()"

			# collect only nodes that has x_absolute and y_absolute attributes
			nodeset.collect!{ | node |

				node unless node.at_xpath( attribute_pattern % 'x_absolute' ).to_s.empty? || node.at_xpath( attribute_pattern % 'y_absolute' ).to_s.empty?

			}.compact!.sort!{ | element_a, element_b |

				element_a_x = element_a.at_xpath( attribute_pattern % 'x_absolute' ).content.to_i
				element_a_y = element_a.at_xpath( attribute_pattern % 'y_absolute' ).content.to_i

				element_b_x = element_b.at_xpath( attribute_pattern % 'x_absolute' ).content.to_i
				element_b_y = element_b.at_xpath( attribute_pattern % 'y_absolute' ).content.to_i

				if ( layout_direction =~ /LeftToRight/i )

					( element_a_y == element_b_y ) ? ( element_a_x <=> element_b_x ) : ( element_a_y <=> element_b_y ) 

				elsif ( layout_direction =~ /RightToLeft/i )

					( element_a_y == element_b_y ) ? ( element_b_x <=> element_a_x ) : ( element_a_y <=> element_b_y ) 

				else

					Kernel::raise ArgumentError.new( "Unexpected layout direction: %s" % layout_direction )

				end

			}

		end
  
	private


		# function create x_path that included required attributes type, id and/or name
		# == returns
		# String:: x_path containing required attributes
		def create_xpath_from_required_attributes

			return "@*" if @_attributes_used_to_identify_object[ :type ].to_s == "any"

			xpath = ""

			pattern = "@%s=%s or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=%s]/value=%s"

			@_attributes_used_to_identify_object.each_pair{ | attribute_name, attribute_value | 

				next unless @@required_attributes.include?( attribute_name )

				xpath << ' and ' unless xpath.empty?

				xpath << '('

				if attribute_value.kind_of?( Array )

					# multiple (optional) attributes for object identification
					attribute_value.each_with_index{ | attribute_value_option, index |
						
						xpath << ' or ' unless index.zero?

						a_v_o = convertToXPathLiteral( attribute_value_option )

						xpath << pattern % [ 
							attribute_name, 
							a_v_o, 
							convertToXPathLiteral( attribute_name.to_s.downcase), 
							a_v_o
						]

					}

				else

					a_v = convertToXPathLiteral( attribute_value )

					# one attribute used for object identification
					xpath << "%s" % [
						pattern % [ 
							attribute_name, 
							a_v, 
							convertToXPathLiteral( attribute_name.to_s.downcase), 
							a_v
						]
					]

				end

				xpath << ')'

			}
			
			xpath

		end

		# Private function to define rule for a given MobyUtil::XML::Element element.
		# Uses xml_elements namespace in the rule. 
		# Uses private instance variable to define the actual rule. Instance variable is set in constructor
		# == params
		# xml_element:: MobyUtil::XML::Element element frow which objects are being identified
		# == returns
		# Array (<String>, Array(<String>) ):: returns array of two element as defined below
		# String:: Rule to be used in xpath
		def xpath_to_identify( get_all_children = true )

			xpath = create_xpath_from_required_attributes

			pattern = "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=%s]/"
			
			@_attributes_used_to_identify_object.each_pair do | attribute_key, attribute_value |

				# Relaxing conditions, no need for mandatory :name, :type, :parent, :id or :__index. See class instance constructor.
				next if @insignificant_attributes.include?( attribute_key ) 
				
				xpath << ' and ' unless xpath.empty?

				xpath << pattern % convertToXPathLiteral( attribute_key.to_s.downcase )

				# convert single value to array, due to value can contain multiple values and no use to have duplicate code for processing
				attribute_value = [ attribute_value ] unless attribute_value.kind_of?( Array ) 

				attribute_value.each_with_index do | value, index |

					xpath << " or " unless index.zero?

					# allow partial match when value of :type and attribute name matches. see class instance constructor.
					if @@partial_match_allowed.include?( [ @_attributes_used_to_identify_object[ :type ], attribute_key ] )

						xpath << "value[contains(.,%s)]" % convertToXPathLiteral( value )

					else

						xpath << "value=%s" % convertToXPathLiteral( value )


					end
				end

			end

			( get_all_children ? "*//object[%s]" : "objects[1]/object[%s]" ) % xpath

		end
	
		# TODO: This method needs to refactored
		# function to deal with case where string literals in XPath expressions contains single or double quotes
		# If string literal value contain only one type - double or single, then delimit with the other.
		# E.g. "'"  or '"'
		# If value contains both then you can not do it directly in a string literal but need to construct the string using
		# concat("'",'"')
		def convertToXPathLiteral( value )

			# convert to string if needed
			value_string = value.kind_of?( String ) ? value : value.to_s

			if !value_string.include?("\'")

				# return value
				"\'%s\'" % value_string

			elsif !value_string.include?("\"")

				# return value
				"\"%s\"" % value_string

			else

				result = ""

				substrings = value_string.split( "\"" )

				substrings.each_with_index do | s, i | 

					needComma = true if i > 0

					unless s.empty?

						result << ", " if i > 0

						result << "\"%s\"" % s 

						needComma = true

					end

					# other than last one 
					if i < substrings.length - 1

						result << ", " if needComma

						result << "'\"'"

					end 

				end

				# return value
				"concat(%s)" % result

			end

		end

	public # deprecated

		# function create x_path that included required attributes type, id and/or name
		# == returns
		# String:: x_path containing required attributes
		def create_x_path_from_required_attributes

			return "@*" if @_attributes_used_to_identify_object[ :type ].to_s == "any"

			xpath = ""

			pattern = "@%s=%s or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=%s]/value=%s"

			@_attributes_used_to_identify_object.each_pair{ | attribute_name, attribute_value | 

				next unless @@required_attributes.include?( attribute_name )

				xpath << ' and ' unless xpath.empty?

				xpath << '('

				if attribute_value.kind_of?( Array )

					# multiple (optional) attributes for object identification
					attribute_value.each_with_index{ | attribute_value_option, index |
						
						xpath << ' or ' unless index.zero?

						xpath << pattern % [ 
							attribute_name, 
							convertToXPathLiteral( attribute_value_option), 
							convertToXPathLiteral( attribute_name.to_s.downcase), 
							convertToXPathLiteral( attribute_value_option)
						]

					}

				else

					# one attribute used for object identification
					xpath << "%s" % [
						pattern % [ 
							attribute_name, 
							convertToXPathLiteral( attribute_value), 
							convertToXPathLiteral( attribute_name.to_s.downcase), 
							convertToXPathLiteral( attribute_value)
						]
					]

				end

				xpath << ')'

			}
			
			xpath

		end

		# Private function to define rule for a given MobyUtil::XML::Element element.
		# Uses xml_elements namespace in the rule. 
		# Uses private instance variable to define the actual rule. Instance variable is set in constructor
		# == params
		# xml_element:: MobyUtil::XML::Element element frow which objects are being identified
		# == returns
		# Array (<String>, Array(<String>) ):: returns array of two element as defined below
		# String:: Rule to be used in xpath
		def get_xpath_to_identify( from_xml_element, namespace = nil, get_all_children= true )

			xpath = create_x_path_from_required_attributes
			pattern = "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')=%s]/"
			
			@_attributes_used_to_identify_object.each_pair do | attribute_key, attribute_value |

				# Relaxing conditions, no need for mandatory :name, :type, :parent, :id or :__index. See class instance constructor.
				next if @insignificant_attributes.include?( attribute_key ) 
				
				xpath << ' and ' unless xpath.empty?

				xpath << pattern % convertToXPathLiteral( attribute_key.to_s.downcase )

				# convert single value to array, due to value can contain multiple values and no use to have duplicate code for processing
				attribute_value = [ attribute_value ] unless attribute_value.kind_of?( Array ) 

				attribute_value.each_with_index do | value, index |

					xpath << " or " unless index.zero?

					# allow partial match when value of :type and attribute name matches. see class instance constructor.
					if @@partial_match_allowed.include?( [ @_attributes_used_to_identify_object[ :type ], attribute_key ] )

						xpath << "value[contains(.,%s)]" % convertToXPathLiteral( value )

					else

						xpath << "value=%s" % convertToXPathLiteral( value )


					end
				end

			end

			( get_all_children ? "*//object[%s]" : "objects[1]/object[%s]" ) % xpath

		end

=begin
		## Returns array of element nodes
		def sort_elements_by_xy_layout( element_set, layout_direction = "LeftToRight" )

			# MobyUtil::XML::NodeSet and Elements
			# Take out all test_objects with no x_absolute or y_absolute
			to_delete = []
			element_set.each do |node|
				begin
					node.xpath("./attributes/attribute[@name = 'x_absolute']/value").first.content
					node.xpath("./attributes/attribute[@name = 'y_absolute']/value").first.content
				rescue
					to_delete << node
				end
			end
			to_delete.each do |node|
				element_set.delete(node) 
			end
			# Sort remaining by layout direction and up to down
			# Requires .to_a to return an array of MobyUtil::XML::Elements
			element_set.to_a.sort!{ |a, b| 
				element_a_x = a.xpath("./attributes/attribute[@name = 'x_absolute']/value").first.content.to_i
				element_a_y = a.xpath("./attributes/attribute[@name = 'y_absolute']/value").first.content.to_i
				element_b_x = b.xpath("./attributes/attribute[@name = 'x_absolute']/value").first.content.to_i
				element_b_y = b.xpath("./attributes/attribute[@name = 'y_absolute']/value").first.content.to_i
				if ( layout_direction.downcase == "LeftToRight".downcase )
					( element_a_y == element_b_y ) ? ( element_a_x <=> element_b_x ) : ( element_a_y <=> element_b_y ) 
				elsif ( layout_direction.downcase == "RightToLeft".downcase ) 
					( element_a_y == element_b_y ) ? ( element_b_x <=> element_a_x ) : ( element_a_y <=> element_b_y ) 
				else
					Kernel::raise ArgumentError.new("Unexpected layout direction: " + layout_direction)
				end
			}
		end
=end

		# Function to identify an object from tasMessage xml content
		# 
		# == params
		# from_xml_element: MobyUtil::XML::Element XML element for TestObject object containing the information from which a child test object is to be identified
		# == return
		# MobyUtil::XML::Element:: found XML fragment, if any
		# == raise
		# MultipleTestObjectsIdentifiedError:: if multiple test objects are identified
		# TestObjectNotFoundError:: if no TestObject can be identified
		# ArgumentError:: if 'from_xml_element' is not of type MobyUtil::XML::Element
		def find_object_data( from_xml_element, layout_direction = nil )

      from_xml_element.check_type( MobyUtil::XML::Element, "Wrong argument type $1 for XML element (expected $2)" )

			#Kernel::raise ArgumentError.new( "Wrong argument type %s for argument 'xml_element' (expected MobyUtil::XML::Element)" % from_xml_element.class ) unless from_xml_element.kind_of?( MobyUtil::XML::Element )

			xpath = get_xpath_to_identify( from_xml_element )

			element_set = from_xml_element.xpath( xpath )
			
			if @_attributes_used_to_identify_object[ :__xy_sorting ] == "true"
				begin
					#layout_direction = parent_test_object.sut.application( :id => parent_test_object.get_application_id ).attribute("layoutDirection")
					element_set = sort_elements_by_xy_layout( element_set, layout_direction ) 
				rescue MobyBase::AttributeNotFoundError
					element_set = sort_elements_by_xy_layout( element_set) 
				end
			end

			ret, size = ( (size = element_set.size).zero? ) ? [ nil, 0 ] : [ element_set[ ( ( index = @_attributes_used_to_identify_object[ :__index ] ) || 0 ).to_i ], ( index.nil? ? size : 1 ) ]    

			Kernel::raise MobyBase::MultipleTestObjectsIdentifiedError.new( "Multiple test objects found with rule:\n#{ xpath }" ) if ( size > 1 )

			Kernel::raise MobyBase::TestObjectNotFoundError.new( "Cannot find object with rule:\n%s" % [ xpath ] ) if ( size.zero? || ret.nil? )

			ret

		end
    
		# Function to identify  all object from tasMessage xml content
		# 
		# == params
		# from_xml_element: MobyUtil::XML::Element XML element for TestObject object containing the information from which a children test object is to be identified
		# find_all_children:: Boolean specifying whether all children under the test node or just immediate children should be retreived.
		# == return
		# MobyUtil::XML::Element:: found XML fragment, if any
		# == raise
		# TestObjectNotFoundError:: if no TestObject can be identified
		# ArgumentError:: if 'from_xml_element' is not of type MobyUtil::XML::Element
		def find_multiple_object_data( from_xml_element, find_all_children, layout_direction = nil )

      from_xml_element.check_type( MobyUtil::XML::Element, "Wrong argument type $1 for XML element (expected $2)" )

			#Kernel::raise ArgumentError.new( "Wrong argument type %s for argument 'xml_element' (expected MobyUtil::XML::Element)" % from_xml_element.class ) unless from_xml_element.kind_of?( MobyUtil::XML::Element )
				
			element_set = from_xml_element.xpath( xpath = get_xpath_to_identify( from_xml_element ,nil,find_all_children) )  
			ret = Array.new
			
			if @_attributes_used_to_identify_object[ :__xy_sorting ] == "true"
				begin
					#layout_direction = parent_test_object.sut.application( :id => parent_test_object.get_application_id ).attribute("layoutDirection")
					element_set = sort_elements_by_xy_layout( element_set, layout_direction ) 
				rescue MobyBase::AttributeNotFoundError
					element_set = sort_elements_by_xy_layout( element_set) 
				end
			end
			
			if @_attributes_used_to_identify_object.has_key?( :__index ) && element_set.size > 1
				ret << element_set[ @_attributes_used_to_identify_object[ :__index ].to_i ]
				size = 1
			else
				ret = element_set
				size = element_set.size
			end

			Kernel::raise MobyBase::TestObjectNotFoundError.new( "Cannot find object with rule:\n#{ xpath }" ) if ( size == 0 or ret == nil)

			ret
		  
		end

		# enable hooking for performance measurement & debug logging
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # TestObjectIdentificator

end # MobyBase
