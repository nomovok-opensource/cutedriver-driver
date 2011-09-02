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

require 'libxml'

module MobyUtil
  
  module XML
    
    module LibXML
            
      module Abstraction

        def nil?
          @xml.nil?
        end

        def name
          @xml.name
        end

        def to_s
          @xml.to_s
        end

        def size
          @xml.size
        end

        def empty?
          @xml.empty?
        end
                
        private
        
        def method_missing( method, *args, &block )
          raise RuntimeError.new("Method '#{ method.to_s }' is not supported by #{ self.class.to_s } (#{ @parser.to_s })" )
        end
        
        # method to create MobyUtil::XML::Element object
        def element_object( xml_data )
          MobyUtil::XML::Element.new().extend( Element ).tap { | element | element.xml = xml_data; element.parser = @parser; }        
        end
        
        # method to create MobyUtil::XML::Nodeset object
        def nodeset_object( xml_data )
          MobyUtil::XML::Nodeset.new().extend( Nodeset ).tap { | node | node.xml = xml_data; node.parser = @parser; }          
        end
        
      end # Abstraction
      
      module Document # behaviour
        include MobyUtil::XML::LibXML::Abstraction 
                
        def parse( xml_string )
          ::LibXML::XML::Parser.string( xml_string ).parse 
        end
        
        def xpath( xpath_query )
          nodeset_object( @xml.find( xpath_query ) )
        end
        
        def root
          element_object( @xml.root )
        end
        
      end # Document
      
      module Element # behaviour
        include MobyUtil::XML::LibXML::Abstraction 

        def inner_xml
          @xml.inner_xml
        end
        
        def xpath( xpath_query )
          element_object( @xml.find( xpath_query ) )
        end

        def first
          self[0]
        end
        
        def []( value )
          element_object( @xml[value] )
        end
        
        def each( &block )
          @xml.each{ | element | yield( element_object( element ) ) }
        end        

        def attribute( attr_name )
          @xml.attributes[ attr_name ].nil? ? nil : @xml.attributes[ attr_name ].to_s
        end
        
        def attributes
          {}.tap{ | hash | @xml.attributes.each{ | attr | hash[attr.name.to_s] = attr.value.to_s } }
        end
        
        def content
          @xml.content.to_s
        end
        
      end # Element
      
      module Nodeset # behaviour
        include MobyUtil::XML::LibXML::Abstraction 
        
        def each( &block )           
          @xml.each{ | element | yield( element_object( element ) ) }
        end
                
        def []( node )
          element_object( @xml[ node ] )
        end
        
      end # Nodeset
      
      
    end # Nokogiri
    
  end # XML
  
end # MobyUtil
