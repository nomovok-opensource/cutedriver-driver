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

module TDriver

  class AttributeFilter

    # TODO: document me
    def self.add_attribute( attribute )

      _attribute = attribute.to_s

      unless @attributes.include?( _attribute )

        @attributes << _attribute.to_s

        @attributes_string = @attributes.join( ',' )

        yield if block_given?

      end

    end

    # TODO: document me
    def self.add_attributes( attributes )

      updated_list = @attributes | attributes.collect{ | value | value.to_s }

      unless updated_list == @attributes

        @attributes = updated_list
        
        @attributes_string = @attributes.join( ',' )

        yield if block_given?

      end

    end

    # TODO: document me
    def self.has_attribute?( attribute )

      @attributes.include?( attribute.to_s )

    end

    # TODO: document me
    def self.filter_string

      @attributes_string

    end

    class << self

      private

      # TODO: document me
      def initialize_class

        @attributes_string = ""

        @attributes = []

      end

    end

    # initialize attribute filter class
    initialize_class

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # AttributeFilter

end # TDriver

# for backwards compatibility
module MobyUtil

  class DynamicAttributeFilter

    def self.instance

      warn_caller '$1:$2 warning: deprecated class MobyUtil::DynamicAttributeFilter; please use static TDriver::AttributeFilter class instead'

      TDriver::AttributeFilter

    end 

  end # DynamicAttributeFilter

end # MobyUtil
