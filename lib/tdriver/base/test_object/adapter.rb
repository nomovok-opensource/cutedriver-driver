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

    class << self
    
      private
      
        # private
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

    def self.test_object_attribute( name, source_data )

      source_data.attribute( name ).to_s

    end

    # public
		# find_all_children:: Boolean specifying whether all children under the test node or just immediate children should be retreived.
    def self.get_objects( source_data, rules )

	    rule = xpath_to_object( rules ) 

			[ 
			  # perform xpath to source xml data
			  source_data.xpath( rule ),
		    rule 
	    ]    
    
    end

    def self.create_child_accessors!( test_object, source_data )

      created_accessors = []

      source_data.xpath( 'objects/object' ).each{ | object_element |

        object_element.attribute( 'type' ).tap{ | object_type |

          unless created_accessors.include?( object_type ) || object_type.empty? then

          test_object.instance_eval(

            "def %s( rules={} ); raise TypeError, 'parameter <rules> should be hash' unless rules.kind_of?( Hash ); rules[:type] = :%s; child( rules ); end;" % [ object_type, object_type ]

          )

          created_accessors << object_type

        end

        }

      }

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObjectAdapter

end # TDriver
