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

      module Document # behaviour

        include Abstraction 

        def parse( xml_string )

          ::Nokogiri::XML.parse( xml_string, nil, 'UTF8', ::Nokogiri::XML::ParseOptions::STRICT )

        end

        def root

          element_object( @xml.root )

        end

        def xpath( xpath_query, *args, &block )

          nodeset_object( @xml.xpath( xpath_query ), *args, &block )

        end

        # enable hooking for performance measurement & debug logging
        MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

      end # Document

    end # Nokogiri

  end # XML

end # MobyUtil
