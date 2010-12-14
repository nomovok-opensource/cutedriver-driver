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

  class TestObjectAdapter

    # private methods and variables
    class << self
    
      private
      
        # TODO: document me
        def xpath_to_object( rules )

          # object element attribute or attribute element 
          test_object_identification_attributes = rules.collect{ | key, value | 
                      
            key = key.to_s.downcase
            
            if [ "name", "type", "parent", "id" ].include?( key )
            
              "(@#{ key }='#{ value }' or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }']/value='#{ value }')"
            else
            
              "(attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }']/value='#{ value }')"
                          
            end
                                 
          }.compact.join(" and ")

          "*//object[#{ test_object_identification_attributes }]" 
        
        end
    
    end

    def self.test_object_hash( object_id, object_type, object_name )
    
			( ( ( 17 * 37 + object_id ) * 37 + object_type.hash ) * 37 + object_name.hash )

    end

		# Sort XML nodeset of test objects with layout direction
		def self.sort_elements( nodeset, layout_direction = "LeftToRight" )

			attribute_pattern = "./attributes/attribute[@name='%s']/value/text()"

			# collect only nodes that has x_absolute and y_absolute attributes
			nodeset.collect!{ | node |

				node unless node.at_xpath( attribute_pattern % 'x_absolute' ).to_s.empty? || node.at_xpath( attribute_pattern % 'y_absolute' ).to_s.empty?

			}.compact!.sort!{ | element_a, element_b |

				element_a_x = element_a.at_xpath( attribute_pattern % 'x_absolute' ).content.to_i
				element_a_y = element_a.at_xpath( attribute_pattern % 'y_absolute' ).content.to_i

				element_b_x = element_b.at_xpath( attribute_pattern % 'x_absolute' ).content.to_i
				element_b_y = element_b.at_xpath( attribute_pattern % 'y_absolute' ).content.to_i

        case layout_direction
        
          when "LeftToRight"

  					( element_a_y == element_b_y ) ? ( element_a_x <=> element_b_x ) : ( element_a_y <=> element_b_y ) 

				  when "RightToLeft"

  					( element_a_y == element_b_y ) ? ( element_b_x <=> element_a_x ) : ( element_a_y <=> element_b_y ) 

				else

					Kernel::raise ArgumentError.new( "Unsupported layout direction #{ layout_direction.inspect }" )

				end

			}

		end

    def self.parent_test_object_element( test_object )

      # retrieve parent of current xml element; objects/object/objects/object/../..
      test_object.xml_data.parent.parent
    
    end
    
    # TODO: document me
    def self.test_object_element_attributes( source_data )

      Hash[
        source_data.attributes.collect{ | key, value | 
          [ key.to_s, value.to_s ]
        }
      ]

    end

    # TODO: document me
    def self.test_object_element_attribute( source_data, name, &block )

      result = source_data.attribute( name )
      
      unless result
            
        if block_given?
        
          yield
        
        else
        
          # raise exception if no such attribute found
          Kernel::raise MobyBase::AttributeNotFoundError.new(
          
            "Could not find test object element attribute #{ attribute_name.inspect }"
            
          )
        
        end
      
      else
      
        result
      
      end

    end

    # TODO: document me
    def self.test_object_attribute( source_data, attribute_name, &block )

      # TODO: consider using at_xpath and adding /value/text() to query string; however "downside" is that if multiple matches found only first value will be returned as result

      # retrieve attribute(s) from xml
      nodeset = source_data.xpath(
       
        "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ attribute_name.downcase }']" # /value/text()"
        
      )

      # if no attributes found call optional code block or raise exception 
      if nodeset.empty? 

        if block_given?

          # pass return value of block as result
          yield

        else

          # raise exception if no such attribute found
          Kernel::raise MobyBase::AttributeNotFoundError.new(
          
            "Could not find attribute #{ attribute_name.inspect }" # for test object of type #{ type.to_s }"
            
          )
          
        end

      else
      
        # attribute(s) found
        # Need to disable this for now 
        # Kernel::raise MobyBase::MultipleAttributesFoundError.new( "Multiple attributes found with name '%s'" % name ) if nodeset.count > 1

        # return found attribute
        nodeset.first.content.strip
        
      end

    end

    # TODO: document me
    def self.test_object_attributes( source_data )
    
      # return hash of test object attributes
      Hash[ 

        # iterate each attribute and collect name and value      
        source_data.xpath( 'attributes/attribute' ).collect{ | test_object | 

          [ test_object.attribute( 'name' ), test_object.at_xpath( 'value/text()' ).to_s ]

        } 

      ]

    end


		# TODO: document me
    def self.get_objects( source_data, rules )

	    rule = xpath_to_object( rules )

			[ 
			  # perform xpath to source xml data
			  source_data.xpath( rule ),
		    rule 
	    ]    
    
    end

    # TODO: document me
    def self.create_child_accessors!( source_data, test_object )

      # iterate through each child object type attribute and create accessor method  
      source_data.xpath( 'objects/object/@type' ).each{ | object_type |

        next if object_type.nil?

        # convert attribute node value to string
        object_type = object_type.content

        # skip if child accessor is already created 
        next if test_object.respond_to?( object_type ) 

        # create child accessor method to test object unless already exists
        test_object.instance_eval(

          "def #{object_type}(rules={}); raise TypeError,'parameter <rules> should be hash' unless rules.kind_of?(Hash); rules[:type]=:#{object_type}; child(rules); end;"

        ) unless object_type.empty?

      }

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObjectAdapter

end # TDriver
