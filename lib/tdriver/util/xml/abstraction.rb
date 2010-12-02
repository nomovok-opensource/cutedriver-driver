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

    module Abstraction

      attr_accessor :xml, :parser

      def initialize( xml = nil, parser = nil )

        @xml, @parser = xml, parser

      end

      def method_missing( *args )

        Kernel::raise RuntimeError.new( "This is abstraction class of %s - XML parser type was not specified correctly" % self.class ) 

      end      

      # print only object type and id hex
      def inspect
      
        "#<#{ self.class }:0x#{ ( "%x" % ( self.object_id.to_i << 1 ) )[ 3 .. -1 ] }>"
            
      end

      # enable hooking for performance measurement & debug logging
      MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

    end # Abstraction

  end # XML

end # MobyUtil
