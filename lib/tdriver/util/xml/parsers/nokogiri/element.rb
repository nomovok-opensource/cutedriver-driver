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

module MobyUtil

  module XML

    module Nokogiri

      module Element # behaviour

        include Abstraction 

        def <=>( object )

          @xml <=> object.xml

        end

        def []( value )

          @xml.attributes[ value ]

        end

        def attributes

          # return hash of attributes
          Hash[ @xml.attributes.collect{ | key, value | [ key, value.to_s ] }]

        end

        def attribute( attr_name )

          unless ( value = @xml.attribute( attr_name ) ).nil?

            value.to_s

          end

        end


        def children

          nodeset_object( @xml.children )

        end

        def content

          unless @xml.nil?

            @xml.content.to_s

          end

        end

        def each( &block )

          @xml.each{ | element | 

            yield( element_object( element ) ) 

          }

          nil

        end        

        def eql?( object )

          @xml.content == object.xml.content

        end

        def empty?

          @xml.nil?

        end

        def inner_xml

          @xml.inner_html.to_s

        end

        def xpath( xpath_query, *args, &block )

          nodeset_object( 

            @xml.xpath( xpath_query, *args, &block ) 

          )

        end

        def at_xpath( xpath_query, *args, &block )

          @xml.at_xpath( xpath_query, *args, &block ).to_s

        end

        def replace( other )

          @xml.replace( other.xml )

          self

        end

        def add_previous_sibling( other )

          @xml.add_previous_sibling( other.xml )

        end

        def remove

          @xml.remove

          self

        end

        def parent
        
          element_object( @xml.parent )
        
        end

        # enable hooking for performance measurement & debug logging
        MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

      end # Element

    end # Nokogiri

  end # XML

end # MobyUtil
