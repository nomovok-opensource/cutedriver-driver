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

      attr_accessor :xml

      # TODO: document me
      def initialize( xml = nil, options = {} )

        @options = options

        @cache = Hash.new{ | hash, key | hash[ key ] = {} }

        @xml = xml

      end

      # TODO: document me
      def clone!

        # create a clone of self object, also xml object is cloned; note that all references (e.g. parent) will be disconnected
        self.class.new( @xml.clone )

      end

      # TODO: document me
      def comment?

        kind_of?( MobyUtil::XML::Comment )

      end

      # TODO: document me
      def text?

        kind_of?( MobyUtil::XML::Text )

      end

      # TODO: document me
      def attribute?

        kind_of?( MobyUtil::XML::Attribute )

      end

      # TODO: document me
      def nodeset?

        kind_of?( MobyUtil::XML::Nodeset )

      end

      # TODO: document me
      def element?

        kind_of?( MobyUtil::XML::Element )

      end

      # TODO: document me
      def document?

        kind_of?( MobyUtil::XML::Document )

      end

      # TODO: document me
      def nil?

        kind_of?( MobyUtil::XML::NilNode )

      end

      # TODO: document me
      def method_missing( *args )

        raise RuntimeError, "This is abstraction class of #{ self.class } - XML parser type was not specified correctly" 

      end      

      # print only object type and id hex
      def inspect
      
        "#<#{ self.class }:0x#{ ( "%x" % ( object_id.to_i << 1 ) )[ 3 .. -1 ] }>"
            
      end

      # enable hooking for performance measurement & debug logging
      TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    end # Abstraction

  end # XML

end # MobyUtil
