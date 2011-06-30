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

  module OptimizedXML

    class TestObjectAdapter

      # private methods and variables
      class << self
      
        private

          # TODO: document me
          def xpath_attributes( attributes, element_attributes, object_type )
    
            # collect attributes
            attributes = attributes.collect{ | key, values |

              # allow multiple values options for attribute, e.g. object which 'text' attribute value is either '1' or '2' 
              ( values.kind_of?( Array ) ? values : [ values ] ).collect{ | value |

                # concatenate string if it contains single and double quotes, otherwise return as is
                value = xpath_literal_string( value )

                prefix_key = "@#{ key }"

                if @partial_match_allowed.include?( [ object_type, key ] )
                  
                  # regexp support is needed also here
                  
                  prefix_value = "[contains(.,#{ value })]"
                  attribute_value = "contains(.,#{ value })"
                
                else

                  if value.kind_of?( Regexp )
                                  
                    prefix_value = "regexp_compare(#{ prefix_key },'#{ value.source }',#{ value.options })"
                    attribute_value = "regexp_compare(.,'#{ value.source }',#{ value.options })"

                    prefix_key = ""
                  
                  else
                  
                    #prefix_value = "=#{ value }"
                    #attribute_value = "text()=#{ value }"

                    prefix_value = "=#{ value }"
                    attribute_value = ".=#{ value }"

                  end
                  
                end

                # construct xpath
                #"(#{ element_attributes ? "#{ prefix_key }#{ prefix_value } or " : "" }attr[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and #{ attribute_value }])"
                "(#{ element_attributes ? "#{ prefix_key }#{ prefix_value } or " : "" }attr[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ key }' and #{ attribute_value }])"
       
              }.join( ' or ' ) # join attribute alternative values
                      
            }.join( ' and ' ) # join all required attributes

            #p attributes

            # return created xpath or nil if no attributes given 
            if attributes.empty?
            
              # no attributes given
              nil
            
            else
            
              # return result 
              attributes
            
            end
            
          end # xpath_attributes
   
          #merges elements from the nodeset, used in hybrid app situations
          def create_merged_element(nodeset, environments, close_element=true)
            merged_element_set = false

            merged_xml = ""

            nodeset.each{ | object |        
             
              # only one top element
              unless merged_element_set

                # retrieve object attributes
                attributes = object.attributes
                
                # merge env to attributes hash
                attributes['env'] = environments.join(';')
                
                # add application object xml element to new xml string
                merged_xml << "<obj #{ hash_to_element_attributes( attributes ) }>"
                
                # merged element is now set, no need to do it again
                merged_element_set = true
                
              end
              
              # append all found elements
              object.xpath('./*').each{ | object | merged_xml << object.to_s }
            }
            merged_xml << "</obj>" if close_element and merged_element_set
            merged_xml
          end

          # TODO: document me
          def initialize_class

        		# special cases: allow partial match when value of type and attribute name matches
            @partial_match_allowed = [ 'list_item', 'text' ], [ 'application', 'fullname' ]

          end
        
      end # static

      # TODO: document me
      def self.regexp_compare( nodeset, source, options ) 
        
        # rebuild defined regexp, used while matching element content
        regexp_object = Regexp.new( source.to_s, options.to_i )
              
        # collect all nodes matching with regexp
        nodeset.find_all{ | node | node.content =~ regexp_object }
      
      end

      # TODO: document me
      def self.xpath_to_object( rules, find_all_children )

        # convert hash keys to downcased string
        rules = Hash[ 

          rules.collect{ | key, value | 

            case value

              # pass the value as is if type of regexp or array; array is used in localisation cases e.g. [ 'one', 'yksi', 'uno' ] # etc
              when Regexp, Array

                [ key.to_s.downcase, value ] 

            else

                [ key.to_s.downcase, value.to_s ] 

            end

          } 

        ]

        # xpath container array
        test_object_xpath_array = []

        # store and remove object element attributes from hash
        object_element_attributes = rules.delete_keys!( 'name', 'type', 'parent', 'id' )

        # children method may request test objects of any type
        if object_element_attributes[ 'type' ] == '*' 

          # test object with any name, type, parent and id is allowed
          test_object_xpath_array << '@*'

        else

          # required attributes          
          test_object_xpath_array << xpath_attributes( object_element_attributes, true, object_element_attributes[ 'type' ] )
        
        end

        # additional attributes, eg. :text, :x, :y etc. 
        test_object_xpath_array << xpath_attributes( rules, false, object_element_attributes[ 'type' ] )

        # join required and additional attribute strings
        test_object_xpath_string = test_object_xpath_array.compact.join( ' and ' )

        # return any child element under current node or only immediate child element 
        #find_all_children ? "*//obj[#{ test_object_xpath_string }]" : "obj[1]/obj[#{ test_object_xpath_string }]"

        find_all_children ? ".//obj[#{ test_object_xpath_string }]" : "obj[#{ test_object_xpath_string }]"

        #"*//obj[#{ test_object_xpath_string }]"
      
      end

      # TODO: document me
      def self.xpath_literal_string( string )

        return string if string.kind_of?( Regexp )

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

        rule = xpath_to_object( rules, find_all_children )

        [ 

          # perform xpath to source xml data
          source_data.xpath( rule, self ),

          # return also created xpath  
          rule

        ]   
      
      end

      # TODO: document me
      def self.test_object_hash( object_id, object_type, object_name )
      
        # calculate test object hash
        ( ( ( 17 * 37 + object_id ) * 37 + object_type.hash ) * 37 + object_name.hash )

      end

      # Sort XML nodeset of test objects with layout direction
      def self.sort_elements( nodeset, layout_direction = 'LeftToRight' )

        # cache for x_absolute and y_absolute values; reduces dramatically number of xpath calls
        cache = {}

        # xpath pattern to be used for x_absolute attribute value
        x_absolute_pattern = './attr[@name="x_absolute"]/text()'

        # xpath pattern to be used for x_absolute attribute value
        y_absolute_pattern = './attr[@name="y_absolute"]/text()'

        # collect only nodes that has x_absolute and y_absolute attributes
        nodeset.collect!{ | node |

          # retrieve x_absolute attribute
          x_absolute = node.at_xpath( x_absolute_pattern )

          # retrieve y_absolute attribute
          y_absolute = node.at_xpath( y_absolute_pattern )

          # return unmodified nodeset if both attributes was not found 
          if x_absolute.nil? || y_absolute.nil?

            #warn("Warning: Unable to sort object set due to object type of #{ node.attribute( 'type' ).inspect } does not have \"x_absolute\" or \"y_absolute\" attribute")

            return nodeset

          else

            # store attributes to cache for further processing
            cache[ node ] = [ x_absolute.content.to_i, y_absolute.content.to_i ]

            # return node as result
            node

          end

        }.compact!.sort!{ | element_a, element_b |

          # retrieve element a's attributes x and y
          element_a_x, element_a_y = cache[ element_a ]

          # retrieve element b's attributes x and y
          element_b_x, element_b_y = cache[ element_b ]

          case layout_direction
          
            when 'LeftToRight'

              # compare elements
              ( element_a_y == element_b_y ) ? ( element_a_x <=> element_b_x ) : ( element_a_y <=> element_b_y ) 

            when 'RightToLeft'

              # compare elements
              ( element_a_y == element_b_y ) ? ( element_b_x <=> element_a_x ) : ( element_a_y <=> element_b_y ) 

          else

            # raise exception if layout direction it not supported 
            Kernel::raise ArgumentError, "Unsupported layout direction #{ layout_direction.inspect }"

          end

        }

      end

      def self.parent_test_object_element( test_object )

        # retrieve parent of current xml element; obj/..
        test_object.xml_data.parent #.parent
      
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
      def self.test_object_element_attribute( source_data, attribute_name, *default, &block )

        result = source_data.attribute( attribute_name )
        
        # if no attribute found call optional code block or raise exception 
        unless result
              
          if block_given?
            
            # pass return value of block as result
            yield( attribute_name )
          
          else
          
            # raise exception if no default value given
            if default.empty?
          
              # raise exception if no such attribute found
              Kernel::raise MobyBase::AttributeNotFoundError, "Could not find test object element attribute #{ attribute_name.inspect }"

            else
            
              # pass default value as result
              default.first
            
            end
          
          end
        
        else
        
          result
        
        end

      end

      # TODO: document me
      def self.test_object_attribute( source_data, attribute_name, *default, &block )

        # TODO: consider using at_xpath and adding text() to query string; however "downside" is that if multiple matches found only first value will be returned as result

        # retrieve attribute(s) from xml
        nodeset = source_data.xpath(
         
          "attr[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#{ attribute_name.downcase }']"
          
        )

        # if no attributes found call optional code block or raise exception 
        if nodeset.empty? 

          if block_given?

            # pass return value of block as result
            yield( attribute_name )

          else

            # raise exception if no default value given
            if default.empty?
            
              # raise exception if no such attribute found
              Kernel::raise MobyBase::AttributeNotFoundError, "Could not find attribute #{ attribute_name.inspect }" # for test object of type #{ type.to_s }"

            else
            
              # pass default value as result
              default.first
            
            end
            
          end # block_given?

        else # not nodeset.empty?
        
          # attribute(s) found
          # Need to disable this for now 
          # Kernel::raise MobyBase::MultipleAttributesFoundError.new( "Multiple attributes found with name '%s'" % name ) if nodeset.count > 1

          # return found attribute
          nodeset.first.content
          
        end

      end

      # TODO: document me
      def self.test_object_attributes( source_data, inclusive_filter = [] )

        # convert all keys to lowercase
        inclusive_filter.collect!{ | key | key.to_s.downcase } unless inclusive_filter.empty?

        # return hash of test object attributes
        object_attributes=Hash.new

          # iterate each attribute and collect name and value
          source_data.xpath( 'attr' ).collect{ | value |

            # retrieve attribute name
            name = value.attribute('name').to_s

            # collect attribute elements name and content
            unless inclusive_filter.empty?

              object_attributes[name]=value.content if inclusive_filter.include?( name.downcase )

            else
              # pass the attribute pair - no filtering done
              if object_attributes[name]
                object_attributes[name]="#{object_attributes[name]},#{value.content}"
              else
                object_attributes[name]=value.content
              end
            end

          }

        object_attributes

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
        #( sut.xml_data.at_xpath('*//obj[@type="application"]/attr[@name="layoutDirection"]/text()').content || 'LeftToRight' ).to_s

        ( sut.xml_data.at_xpath('.//obj[@type="application"]/attr[@name="layoutDirection"]/text()').content || 'LeftToRight' ).to_s

      end

      # TODO: document me
      def self.create_child_accessors!( source_data, test_object )

        # iterate through each child object type attribute and create accessor method  
        source_data.xpath( 'obj/@type' ).each{ | object_type |

          # skip if object type value is nil or empty due to child accessor cannot be created
          next if object_type.nil? || object_type.to_s.empty?

          # convert attribute node value to string
          object_type = object_type.content

          # skip if child accessor is already created 
          next if test_object.respond_to?( object_type ) 

          begin

            # create child accessor method to test object unless already exists
            test_object.instance_eval(

              "def #{ object_type }( rules = {} ); raise TypeError,'parameter <rules> should be hash' unless rules.kind_of?( Hash ); rules[ :type ]=:#{ object_type }; child( rules ); end;"

            ) unless object_type.empty?

          # in case if object type has some invalid characters, e.g. type is "ns:object"
          rescue SyntaxError
    
            warn "warning: unable to create accessor to child test object whose type is #{ object_type.inspect }"

          end

        }

      end

      # TODO: document me
      def self.state_object_xml( source_data, id )
      
        # collect each object from source xml
        objects = source_data.xpath( 'tasInfo/obj' ).collect{ | element | element.to_s }.join
      
        # return xml root element
        MobyUtil::XML.parse_string( 
          "<sut name='sut' type='sut' id='#{ id }'>#{ objects }</sut>"
        ).root
      
      end

      def self.retrieve_parent_application( xml_source )

        xml_source_iterator = xml_source.clone

        while xml_source_iterator.kind_of?( MobyUtil::XML::Element )

          if ( test_object_element_attribute( xml_source_iterator, 'type' ) == 'application' )

            return xml_source_iterator

          end

          if xml_source_iterator.kind_of?( MobyUtil::XML::Element )

            xml_source_iterator = xml_source_iterator.parent

          else
          
            # not found from xml tree
            break
          
          end

        end

        #warn("warning: unable to retrieve parent application")

        raise MobyBase::TestObjectNotFoundError, "Unable to retrieve parent application"

        # return application object or nil if no parent found
        # Does is make sense to return nil - shouldn't all test objects belong to an application? Maybe throw exception if application not found
        
        #nil
      
        #return @sut.child( :type => 'application' ) rescue nil
            
      end
      
      # TODO: document me
      def self.get_xml_element_for_test_object( test_object )
        
        # retrieve nodeset from sut xml_data
        nodeset = test_object.instance_variable_get( :@sut ).xml_data.xpath( test_object.instance_variable_get( :@x_path ) )

        # raise exception if no test objects found 
			  Kernel::raise MobyBase::TestObjectNotFoundError if nodeset.empty?
			
        # return first test object from the nodeset
			  nodeset.first
      
      end

      # TODO: document me    
      def self.get_test_object_identifiers( xml_source, test_object = nil )

        # retrieve parent xpath if test_object given
        parent_xpath = test_object ? test_object.instance_variable_get( :@parent ).x_path : ""
      
        # retrieve type attribute
        type = xml_source.attribute( 'type' )

        # retrieve id attribute
        id = xml_source.attribute( 'id' )

        # retrieve env attribute
        env = xml_source.attribute( 'env' )

        # retrieve test object element attributes and return array containting xpath to test object, name, type and id elements
        [ 
          # x_path to test object
          #test_object ? "#{ parent_xpath }/*//obj[@type='#{ type }' and @id='#{ id }']" : nil,

          test_object ? "#{ parent_xpath }/.//obj[@type='#{ type }' and @id='#{ id }']" : nil,

          # test object name 
          xml_source.attribute( 'name' ),
          
          # test object type 
          type,
          
          # test object id 
          id,

          env
          
        ]

      end

      # TODO: document me
      def self.hash_to_element_attributes( hash )

        hash.collect{ | key, value | 

          "#{ key.to_s }=\"#{ value.to_s }\"" 

        }.join(' ')

      end

	    # TODO: document me
      def self.merge_application_elements( xml_string )
      
        # parse the ui state xml
        document_root = MobyUtil::XML.parse_string( xml_string ).root

        # retrieve application objects as nodeset
        nodeset = document_root.xpath('/tasMessage/tasInfo/obj')

        # check if multiple application objects found
        if nodeset.count > 1

          # new header, apply original element attributes
          new_xml = "<tasMessage #{ hash_to_element_attributes( document_root.attributes )  }><tasInfo #{ hash_to_element_attributes( nodeset.first.parent.attributes ) }>"

          # flag defining that is application element already created
          application_element_set = false

          # collect environment values
          environments = document_root.xpath('/tasMessage/tasInfo/obj[@type="application"]/@env').collect{ | attribute | attribute.to_s }

          #limit to apps
          nodeset = document_root.xpath('/tasMessage/tasInfo/obj[@type="application"]')          
          close_vkb = false
          if nodeset.count > 0
            new_xml << create_merged_element(nodeset, environments, false) 
            close_vkb = true
          end
          # do the same to the vkbs
          environments = document_root.xpath('/tasMessage/tasInfo/obj[@type="vkb_app"]/@env').collect{ | attribute | attribute.to_s }
          nodeset = document_root.xpath('/tasMessage/tasInfo/obj[@type="vkb_app"]')
          new_xml << create_merged_element(nodeset, environments, close_vkb)

          # multiple applications found, return merged application xml
          new_xml << "</obj></tasInfo></tasMessage>"

        else
        
          # only one application found, return data as is
          xml_string
        
        end

      end

      # TODO: document me
      def self.list_test_objects_as_string( source_data )

        source_data.collect{ | object |
            
          path = [ object.attribute( 'type' ) ]

          while object.attribute( 'type' ) != 'application' do
          
            # object/objects/object/../..
            object = object.parent
            
            path << object.attribute( 'type' )
          
          end

          path.reverse.join( '.' )
        
        }.sort
      
      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      # initialize TDriver::TestObjectAdapter
      initialize_class

    end # TestObjectAdapter

  end # OptimizedXML

end # TDriver
