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

# extend Ruby Object class functionality
class Object

  # Compare receiver object type with given types. Raises exception is class name does not equal.
  def check_type( types, message = "wrong argument type $1 (expected $2)" )

    # raise exception if message is not type of String
    raise TypeError.new( "wrong argument type %s for message (expected String)" % [ message.class ] ) unless message.kind_of?( String )

    # create array of types
    type_array = types.kind_of?( Array ) ? types : [ types ]

    # default result value
    found = false

    # collect verbose type list
    verbose_type_list = type_array.each_with_index.collect{ | type, index | 

      raise TypeError.new( "invalid argument type #{ type } for check_type. Did you mean #{ type.class }?" ) unless type.kind_of?( Class )

      found = true if self.kind_of?( type )

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < type_array.count ? ", " : " or " ) : "" ) }#{ type.to_s }"
          
    }.join

    # raise exception if type did not match
    unless found

      # convert macros
      [ self.class, verbose_type_list, self.inspect ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise TypeError.new( message )

    end

    # pass self as return value
    self

  end

end
