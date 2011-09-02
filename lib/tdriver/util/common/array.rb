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

  class ArrayHelper

    def self.rindex_regexp( array, pattern )

      array.check_type Array, 'wrong argument type $1 for array (expected $2)'
      pattern.check_type Regexp, 'wrong argument type $1 for regular expression pattern (expected $2)'

      # return nil if no matches found, otherwise return index of value
      return nil if ( array.reverse.each_index{ | index | return @rindex if array[ ( @rindex = ( ( array.size-1 ) - index ) ) ] =~ pattern; } )

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ArrayHelper

end # MobyUtil
