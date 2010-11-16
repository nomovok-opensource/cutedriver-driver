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

# extend Ruby Hash class functionality
class Hash

  # Verify that received object contains given key. Raises exception is key not found.
  def require_key( keys, message = "Required key(s) $1 not found from hash" )

    # create array of types
    keys_array = keys.kind_of?( Array ) ? keys : [ keys ]    

    found = false

    verbose_keys_list = keys_array.each_with_index.collect{ | key, index | 

      found = true if self.has_key?( key )

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < keys_array.count ? ", " : " and " ) : "" ) }#{ key.inspect }"
          
    }.join

    # raise exception if type did not match
    unless found

      # convert macros
      [ verbose_keys_list ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise ArgumentError.new( message )

    end

    self

  end

  # store keys and values to hash if not already defined
  def default_values( hash )

    hash.each_pair{ | key, value |

      self[ key ] ||= value

    }

    self

  end

  # store key and avalue to hash if not already defined
  def default_value( key, value )

    self[ key ] ||= value

    self

  end

end
