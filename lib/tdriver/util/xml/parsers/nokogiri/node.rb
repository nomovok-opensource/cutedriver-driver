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

      module Node # behaviour

        include Abstraction 

        # TODO: document me
        def []( value )

          @xml[ value ]

        end

        # TODO: document me
        def []=( name, value )

          @xml[ name ] = value

        end

        # TODO: document me
        def ==( object )

          @xml.content == object.xml.content

        end

        # aliases for ==
        alias_method :eql?, :==

        # TODO: document me
        def <=>( object )

          @xml <=> object.xml

        end

        # TODO: document me
        def add_previous_sibling( other )

          @xml.add_previous_sibling( other.xml )

        end

        # TODO: document me
        def attribute( attr_name )

          unless ( value = @xml.attribute( attr_name ) ).nil?

            value.to_s

          end

        end

        # TODO: document me
        def attributes

          # return hash of attributes
          Hash[ @xml.attribute_nodes.collect{ | node | 

            [ node.node_name, node.value.to_s ] }

          ]

        end

        # TODO: document me
        def blank?

          @xml.blank?

        end

        # TODO: document me
        def children

          node_object( @xml.children )

        end

        # TODO: document me
        def content

          @xml.content

        end

        # aliases for text
        alias_method :text, :content
        alias_method :inner_text, :content

        # TODO: document me
        def each( &block )

          # iterate each attribute
          @xml.each{ | element | 

            yield( node_object( element ) ) 

          }

          nil

        end        

        # TODO: document me
        def inner_html

          @xml.inner_html

        end

        # aliases for inner_html
        alias_method :inner_xml, :inner_html

        # TODO: document me
        def to_s
  
          @xml.to_s

        end

        # TODO: document me
        def parent
        
          node_object( @xml.parent )
        
        end

        # TODO: document me
        def remove

          @xml.remove

          self

        end

        # TODO: document me
        def replace( other )

          @xml.replace( other.xml )

          self

        end

        # TODO: document me
        def xpath( xpath_query, *args, &block )

          node_object( 

            @xml.xpath( xpath_query, *args, &block ) 

          )

        end

        # TODO: document me
        def at_xpath( xpath_query, *args, &block )

          node_object( 

            @xml.at_xpath( xpath_query, *args, &block ) 

          )

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Element

    end # Nokogiri

  end # XML

end # MobyUtil
