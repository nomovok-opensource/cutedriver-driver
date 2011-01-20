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

  class StackableValue

    # TODO: document me
    def initialize( value, explicit_format = [] )

      @explicit_format = explicit_format.kind_of?( Array ) ? explicit_format : [ explicit_format ]

      @stack = []

      push( value )

    end

    # TODO: document me
    def push( value )

      unless @explicit_format.empty?

        found = false

        # collect verbose type list
        verbose_type_list = @explicit_format.each_with_index.collect{ | type, index | 

          raise TypeError, "invalid argument type #{ type } for check_type. Did you mean #{ type.class }?" unless type.kind_of?( Class )

          found = true if value.kind_of?( type )

          # result string, separate types if multiple types given
          "#{ ( ( index > 0 ) ? ( index + 1 < @explicit_format.count ? ", " : " or " ) : "" ) }#{ type.to_s }"
              
        }.join

        raise TypeError, "wrong variable format #{ value.class } for stackable value (expected #{ verbose_type_list })" unless found

      end

      # add to stack
      @stack << value

    end

    # TODO: document me
    def pop

      @stack.pop unless ( @stack.count == 1 )

      # return last value from stack
      @stack.last

    end

    # TODO: document me
    def restore

      @stack = [ @stack.first ]

      # return first value in stack array
      @stack.last

    end

    # TODO: document me
    def stacked?

      # determine if there is values in stack
      @stack.count > 1

    end

    # TODO: document me  
    def to_s

      # return last value in stack array as string
      @stack.last.to_s

    end

    # TODO: document me
    def inspect

      # return inspect of last value in stack array
      @stack.last.inspect

    end

    # TODO: document me
    def count

      # return size of the stack array
      @stack.count

    end

    # TODO: document me
    def first

      # return first value in stack array
      @stack.first

    end

    # TODO: document me
    def last

      # return last value in stack array
      @stack.last

    end

    # TODO: document me
    def []( value )

      # return last one if index is too high
      value = -1 if ( value > @stack.count - 1 )

      @stack[ value ]

    end

    def ==( value )

      @stack.last == value

    end

    # TODO: document me
    def kind_of?( klass )

      # compary stacked value class 
      @stack.last.kind_of?( klass ) or klass == TDriver::StackableValue

    end

    # create required aliases
    alias_method :size, :count

    alias_method :<<, :push

    alias_method :eql?, :==

  end # StackableValue

end # TDriver
