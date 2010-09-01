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

        # method to create MobyUtil::XML::Attribute object
        def attribute_object( xml_data )

          MobyUtil::XML::Attribute.new( xml_data, @parser ).extend( Attribute )

        end

        # method to create MobyUtil::XML::Element or MobyUtil::XML::NilElement object 
        def element_object( xml_data )

          unless xml_data.nil?

            MobyUtil::XML::Element.new( xml_data, @parser ).extend( Element )

          else

            MobyUtil::XML::NilElement.new( nil, @parser )

          end

        end

        # method to create MobyUtil::XML::Nodeset object
        def nodeset_object( xml_data )

          MobyUtil::XML::Nodeset.new( xml_data, @parser ).extend( Nodeset )


        end

        # TODO: Documentation
        def method_missing( method, *args, &block )

          raise RuntimeError.new( "Method '%s' is not supported by %s (%s)" % [ method, self.class, @parser ] )

        end

        # enable hooking for performance measurement & debug logging
        MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

      end # Abstraction

     end # Nokogiri

  end # XML

end # MobyUtil
