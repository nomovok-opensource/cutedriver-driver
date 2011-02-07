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

class Exception

  # TODO: document me
  def nested_backtrace

    if backtrace

      _backtrace = backtrace.dup
      
      begin

        _backtrace[ 0 ] = "#{ _backtrace.first.to_s } raised #{ self.class.name }: #{ message.to_s }"

        _backtrace.unshift( caller.first )

      rescue
      
        # exception raised, do not alter backtrace

      end

    else
    
      # no backtrace available
      _backtrace = []
    
    end

    # return backtrace array
    _backtrace

  end

end # Exception
