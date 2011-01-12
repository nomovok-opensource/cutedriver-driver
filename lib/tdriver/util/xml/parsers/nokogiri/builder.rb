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

      module Builder # behaviour

        def build( &block )

          @xml = ::Nokogiri::XML::Builder.new( &block )

        end

        def to_xml

          @xml.to_xml

        end

        # support all Nokogiri::XML::Builder class instance methods
        def method_missing( method, *args )

          Kernel::raise NoMethodError.new( "Method '%s' is not supported by %s" % [ method, self.class ] ) unless @xml.respond_to?( method )

          @xml.send( method.to_sym, *args )

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Document

    end # Nokogiri

  end # XML

end # MobyUtil
