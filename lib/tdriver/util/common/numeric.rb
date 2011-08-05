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

# extend Ruby Numeric class functionality
class Numeric

  # TODO: document me
  def positive?

    self > 0

  end

  # TODO: document me  
  def non_negative?

    self >= 0

  end

  # TODO: document me  
  def non_positive?

    self <= 0  

  end

  # TODO: document me  
  def negative?

    self < 0

  end

  # TODO: document me
  def not_negative( message = 'Given value ($1) must not be negative', exception = ArgumentError )

    if negative?

      # replace macros
      message.gsub!( '$1', self.inspect )

      raise exception, message, caller

    end
  
    self
    
  end

  # TODO: document me
  def not_zero( message = 'Given value must not be zero', exception = ArgumentError )

    if zero?

      # replace macros
      message.gsub!( '$1', self.inspect )

      raise exception, message, caller

    end
      
    self
  
  end

  # TODO: document me
  def not_positive( message = 'Given value ($1) must not be positive', exception = ArgumentError )

    if positive?

      # replace macros
      message.gsub!( '$1', self.inspect )

      raise exception, message, caller

    end
  
    self
  
  end

  # TODO: document me
  def check_range( range, message = "value $1 is out of range ($2)"  )

    # check that given argument is type of Range
    raise TypeError, 'wrong argument type #{ range.class } for range (expected Range)' unless range.kind_of?( Range )

    # check that given argument is type of Range
    raise TypeError, 'wrong argument type #{ message.class } for exception message (expected String)' unless message.kind_of?( String )

    # replace macros
    message.gsub!( '$1', self.inspect )
    
    message.gsub!( '$2', range.inspect )

    # raise exception if number is out of range
    raise RangeError, message unless range.include?( self )
    
    # return self
    self
    
  end

  # TODO: document me
  def limit( minimum_value, maximum_value )

    # limit current value
    self.min( minimum_value ).max( maximum_value )

  end

  # TODO: document me
  def max( value )

    if value.kind_of?( Numeric )

      self > value ? value : self

    else

      raise TypeError, "wrong type #{ value.class } for value (expected Numeric)"

    end

  end

  # TODO: document me
  def min( value )

    if value.kind_of?( Numeric )

      self < value ? value : self

    else

      raise TypeError, "wrong type #{ value.class } for value (expected Numeric)"

    end

  end

end
