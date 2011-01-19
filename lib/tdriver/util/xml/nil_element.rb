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

    class NilElement

      include Abstraction

      def method_missing( method, *method_arguments )

        raise RuntimeError.new( "Method '%s' is not supported by %s (%s)" % [ method, self.class, @parser ] )

      end

      def xml=( value )

        @xml = nil

      end

      def name

        nil

      end

      def size

        0

      end

      def nil?

        true

      end

      def eql?( object )

        nil == object.xml.content

      end

      def empty?

        true

      end

      def to_s

        ""

      end

      def inner_xml

        ""

      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # NilElement

  end # XML

end # MobyUtil
