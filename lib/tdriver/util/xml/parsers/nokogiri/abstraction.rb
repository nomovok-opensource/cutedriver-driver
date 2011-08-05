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

      module Cache
      
        private
      
        # TODO: document me
        def initialize_cache
                
          @cache = Hash.new{ | hash, key | hash[ key ] = {} }

        end
      
        # TODO: document me
        def clear_cache
        
          @cache.clear
        
        end
      
        # TODO: document me
        def cache( key, value )

          if @options[ :cache_enabled ] == true
          
            @cache[ key ].fetch( value ){

              @cache[ key ][ value ] = yield

            }

          else

            yield
              
          end
                
        end
      
        # TODO: document me
        def no_cache( *args )
        
          yield
        
        end
      
      end
  
      module Abstraction

        include Cache

        # TODO: Documentation
        def name

          cache( :name, :value ){ @xml.name }

        end

        # TODO: Documentation
        def nil?

          cache( :nil?, :value ){ @xml.nil? }

        end

        alias :empty? :nil?

        # TODO: Documentation
        def size

          cache( :size, :value ){ @xml.size }

        end

        # TODO: Documentation
        def to_s

          cache( :to_s, :value ){ @xml.to_s }

        end

      private

        # TODO: document me
        def node_object( object )

          case object

            when ::Nokogiri::XML::Element

              XML::Element.new( object, @options )

            when ::Nokogiri::XML::NodeSet

              XML::Nodeset.new( object, @options )

            when ::Nokogiri::XML::Text

              XML::Text.new( object, @options )

            when ::Nokogiri::XML::Attr

              XML::Attribute.new( object, @options )

            when ::Nokogiri::XML::Comment

              XML::Comment.new( object, @options )

            when ::NilClass

              #nil_node
              MobyUtil::XML::NilNode.new( nil )

            # do not create wrapper object if already wrapped
            when ::MobyUtil::XML::Element, ::MobyUtil::XML::Nodeset, ::MobyUtil::XML::Text, ::MobyUtil::XML::Attribute, ::MobyUtil::XML::NilNode, ::MobyUtil::XML::Comment
            
              object

          else

             raise NotImplementedError, "Object wrapper for #{ object.class } not implemented - Please contact TDriver support"

          end

        end

        # TODO: Documentation
        def method_missing( method, *args, &block )

          raise RuntimeError, "Method #{ method.to_s.inspect } is not supported by #{ self.class } object (#{ MobyUtil::XML.current_parser })"

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Abstraction

     end # Nokogiri

  end # XML

end # MobyUtil
