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

  # TODO: document me
  def blank?
  
    respond_to?( :empty? ) ? empty? : !self
  
  end

  # TODO: document me
  def true?

    false
  
  end
  
  # TODO: document me
  def false?
  
    false
  
  end

  # TODO: document me
  def not_blank( message = "object must not be blank", exception = ArgumentError )

    raise exception, message, caller if blank? 

    self

  end
  
  # define method to class instance
  def meta_def( method_name, &block )
  
    ( class << self; self; end ).instance_eval{ define_method method_name, &block }
    
  end

  # Compare receiver object type with given types. Raises exception is class name does not equal.
  def check_type( types, message = "wrong argument type $1 (expected $2)" )

    # raise exception if message is not type of String
    raise TypeError, "wrong argument type #{ message.class } for message (expected String)", caller unless message.kind_of?( String )

    # create array of types
    type_array = Array( types )

    # default result value
    found = false

    # collect verbose type list
    verbose_type_list = type_array.each_with_index.collect{ | type, index | 

      raise TypeError, "invalid argument type #{ type } for check_type. Did you mean #{ type.class }?", caller unless type.kind_of?( Class )

      if self.kind_of?( type )

        found = true 

        break

      end

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < type_array.count ? ", " : " or " ) : "" ) }#{ type.to_s }"
          
    }

    # raise exception if type did not match
    unless found

      # convert macros
      [ self.class, verbose_type_list.join, self.inspect ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise TypeError, message, caller

    end

    # pass self as return value
    self

  end

  def not_nil( message = "Value must not be nil", exception = ArgumentError )

    raise exception, message, caller unless self

    self

  end

  def validate( values, message = "Unexpected value $3 for $1 (expected $2)" )

    # raise exception if message is not type of String
    raise TypeError, "wrong argument type #{ message.class } for message (expected String)", caller unless message.kind_of?( String )

    # create array of values
    values_array = Array( values )

    # default result value
    found = false

    # collect verbose type list
    verbose_values_list = values_array.each_with_index.collect{ | value, index | 

      raise TypeError, "Invalid argument type #{ value.class } for value (expected #{ self.class })", caller unless value.kind_of?( self.class )

      if self == value
      
        found = true 
        
        break
        
      end

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < values_array.count ? ", " : " or " ) : "" ) }#{ value.inspect }"
          
    }

    # raise exception if value was not found
    unless found

      # convert macros
      [ self.class, verbose_values_list.join, self.inspect ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise ArgumentError, message, caller

    end

    # pass self as return value
    self
        
  end

end
