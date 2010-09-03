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


=begin

module MobyUtil

  module XML

    module Nokogiri

      module Attribute

        def value
          @xml.nil? ? nil : @xml.value.to_s
        end

        def name
          @xml.nil? ? nil : @xml.name
        end

        #def to_s
          #  value
        #end

        # enable hooking for performance measurement & debug logging
        MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

      end      

    end # Nokogiri

  end # XML

end # MobyUtil

=end
