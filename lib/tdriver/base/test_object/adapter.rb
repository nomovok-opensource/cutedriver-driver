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
        def xpath_to_object( rules, find_all_children )

          p __method__

          # object element attribute or attribute element 
          test_object_identification_attributes = rules.collect{ | key, value | 
                      
            key = key.to_s.downcase
            
            if [ "name", "type", "parent", "id" ].include?( key )

              # TODO: change "any" to "*"
              # children method may request test objects of any type
              if key == 'type' and value == 'any'
              
                '@*'
                
              else

                "(@#{ key }='#{ value }' or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and .=#{ xpath_literal_string( value ) }])"

                #"(@#{ key }='#{ value }' or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and .='#{ value }'])"

                                
                #"(@#{ key }='#{ value }' or attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }']/value='#{ value }')"
              
              end
              
            else
            
              # TODO: add support for having multiple value options 
            
=begin
                attribute_value.each_with_index do | value, index |

                  xpath << " or " unless index.zero?

                  # allow partial match when value of :type and attribute name matches. see class instance constructor.
                  if @@partial_match_allowed.include?( [ @_attributes_used_to_identify_object[ :type ], attribute_key ] )

                    xpath << "value[contains(.,%s)]" % convertToXPathLiteral( value )

                  else

                    xpath << "value=%s" % convertToXPathLiteral( value )

                  end
                  
                end
                
=end            
            
              #"(attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }']/value='#{ value }')"

              "(attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and .=#{ xpath_literal_string( value ) }])"
               
              #"(attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and .='#{ value }'])"
           
            end
                                 
          }.compact.join(" and ")

        p find_all_children ? "*//object[#{ test_object_identification_attributes }]" : "objects[1]/object[#{ test_object_identification_attributes }]"

          find_all_children ? "*//object[#{ test_object_identification_attributes }]" : "objects[1]/object[#{ test_object_identification_attributes }]"
        
        end
    
    end

    # TODO: document me
    def self.xpath_literal_string( string )

      # make sure that argument is type of string
      string = string.to_s
      
      # does not contain no single quotes
      if not string.include?("'")
      
        result = "'#{ string }'"

      # does not contain no double quotes
      elsif not string.include?('"')

        result = "\"#{ string }\""

      # contains single and double quotes  
      else
      
        # open new item
        result = ["'"]

        # iterate through each character  
        string.each_char{ | char |
        
          case char
          
            # encapsulate single quotes with double quotes
            when "'"
              
              # close current item
              result.last << char
              
              # add encapsulated single quote
              result << "\"'\""
              
              # open new item
              result << char
                       
            else
            
              # any other character will appended as is
              result.last << char
            
          end

        }  

        # close last sentence
        result.last << "'"
            
        # create concat clause for xpath
        result = "concat(#{ result.join(',') })"
          
      end

      result

    end

    # TODO: document me
    def self.get_objects( source_data, rules, find_all_children )

      #p __method__

      rule = xpath_to_object( rules, find_all_children )

      [ 
        # perform xpath to source xml data
        source_data.xpath( rule ),
        rule 
      ]    
    
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
    def self.application_layout_direction( sut )

      # temporary fix until testobject will be associated to parent application object
      unless MobyUtil::DynamicAttributeFilter.instance.has_attribute?( 'layoutDirection' )
        
        # temporary fix: add 'layoutDirection' to dynamic attributes filtering whitelist...
        MobyUtil::DynamicAttributeFilter.instance.add_attribute( 'layoutDirection' ) 
        
        # temporary fix: ... and refresh sut to retrieve updated xml data
        sut.refresh
      
      end 
            
      # TODO: parent application test object should be passed to get_test_objects; TestObjectAdapter#test_object_attribute( @app.xml_data, 'layoutDirection')
      ( sut.xml_data.at_xpath('*//object[@type="application"]/attributes/attribute[@name="layoutDirection"]/value/text()').content || 'LeftToRight' ).to_s

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
