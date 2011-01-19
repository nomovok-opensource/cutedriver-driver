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

      module Abstraction

        # TODO: Documentation
        def empty?

          @xml.empty?

        end

        # TODO: Documentation
        def name

          @xml.name

        end

        # TODO: Documentation
        def nil?

          @xml.nil?

        end

        # TODO: Documentation
        def size

          @xml.size

        end

        # TODO: Documentation
        def to_s

          @xml.to_s

        end

      private

        # TODO: document me
        def node_object( object )

          case object

            when ::Nokogiri::XML::Element

              element_object( object )

            when ::Nokogiri::XML::Text

              text_object( object )

            when ::Nokogiri::XML::Attr

              attribute_object( object )

            when ::NilClass

              nil_node

            # do not create wrapper object if already wrapped
            when ::MobyUtil::XML::Element, ::MobyUtil::XML::Nodeset, ::MobyUtil::XML::Text, ::MobyUtil::XML::Attribute, ::MobyUtil::XML::NilNode 
            
              object

          else

             raise NotImplementedError.new( "Object wrapper for node type of #{ object.class } not implemented - Please contact TDriver support" )

          end

        end

        # method to create MobyUtil::XML::Attribute object
        def attribute_object( xml_data )

          #MobyUtil::XML::Attribute.new( xml_data, @parser ).extend( Attribute )
          MobyUtil::XML::Attribute.new( xml_data, @parser )

        end

        # method to create MobyUtil::XML::Element 
        def element_object( xml_data )

          #MobyUtil::XML::Element.new( xml_data, @parser ).extend( Element )
          MobyUtil::XML::Element.new( xml_data, @parser )

        end

        # method to create MobyUtil::XML::NilNode
        def nil_node

            MobyUtil::XML::NilNode.new( nil, @parser )

        end

        # method to create MobyUtil::XML::Text
        def text_object( xml_data )

          #MobyUtil::XML::Text.new( xml_data, @parser ).extend( Text )
          MobyUtil::XML::Text.new( xml_data, @parser )

        end

        # method to create MobyUtil::XML::Nodeset object
        def nodeset_object( xml_data )

          #MobyUtil::XML::Nodeset.new( xml_data, @parser ).extend( Nodeset )
          MobyUtil::XML::Nodeset.new( xml_data, @parser )

        end

        # TODO: Documentation
        def method_missing( method, *args, &block )

          raise RuntimeError, "Method '#{ method }' is not supported by #{ self.class } (#{ @parser })"

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Abstraction

     end # Nokogiri

  end # XML

end # MobyUtil
