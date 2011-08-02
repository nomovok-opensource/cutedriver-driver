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

          cache( __method__, value ){ @xml[ value ] }

        end

        # TODO: document me
        def []=( name, value )

          clear_cache

          @xml[ name ] = value

        end

        # TODO: document me
        def ==( object )

          cache( __method__, object.object_id ){ @xml.content == object.xml.content }
          
        end

        # aliases for ==
        alias_method :eql?, :==

        # TODO: document me
        def <=>( object )

          cache( __method__, object.object_id ){ @xml <=> object.xml }

        end

        # TODO: document me
        def add_previous_sibling( other )

          clear_cache

          @xml.add_previous_sibling( other.xml )

        end

        # TODO: document me
        def attribute( attr_name )

          cache( :attribute, attr_name ){ _attribute( @xml.attribute( attr_name ) ) }

        end

        # TODO: document me
        def attributes

          cache( :attributes, :value ){
            
            # return hash of attributes            
            #Hash[ @xml.attribute_nodes.collect{ | node | 
            #  [ node.node_name, node.value.to_s ] }
            #]

            # approx. 20% faster
            @xml.attribute_nodes.inject({}){ | result, node | result[ node.node_name ] = node.value; result }

          }

        end

        # TODO: document me
        def blank?

          cache( :is_blank, :value ){ @xml.blank? }

        end

        # TODO: document me
        def children

          cache( :children, :value ){ node_object( @xml.children ) }

        end

        # TODO: document me
        def content

          cache( :content, :value ){ @xml.content }

        end

        # aliases for text
        alias_method :text, :content
        alias_method :inner_text, :content

        # TODO: document me
        def each( &block )

          # iterate each attribute
          @xml.each{ | element | 

            yield( cache( :each, element ){ node_object( element ) } )

          }

          nil

        end        

        # TODO: document me
        def inner_html

          cache( :inner_html, :value ){ @xml.inner_html }

        end

        # aliases for inner_html
        alias_method :inner_xml, :inner_html

        # TODO: document me
        def to_s

          cache( :to_s, :value ){ @xml.to_s }

        end

        # TODO: document me
        def parent
        
          cache( :parent, :value ){ node_object( @xml.parent ) }
        
        end

        # TODO: document me
        def remove

          clear_cache

          @xml.remove

          self

        end

        # TODO: document me
        def replace( other )

          clear_cache

          @xml.replace( other.xml )

          self

        end

        # TODO: document me
        def xpath( xpath_query, *args, &block )

          cache( :xpath, xpath_query ){ node_object( @xml.xpath( xpath_query, *args, &block ) ) }

        end

        # TODO: document me
        def at_xpath( xpath_query, *args, &block )

          cache( :at_xpath, xpath_query ){ node_object( @xml.at_xpath( xpath_query, *args, &block ) ) }

        end

      private
      
        def _attribute( value )
        
          value.to_s unless value.nil?
        
        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Element

    end # Nokogiri

  end # XML

end # MobyUtil
