############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
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

module MobyBehaviour

    # == description
    # Example description
    #
    # == behaviour
    # ExampleBehaviour
    #
    # == requires
    # *
    #
    # == input_type
    # *
    #
    # == sut_type
    # *
    #
    # == sut_version
    # *
    #
    # == objects
    # *;sut
    #
    module Gesture
      
    attr_accessor :attribute_accessor_example

    attr_reader :attribute_reader_example

    attr_writer :attribute_writer_example
      
    # overwrite attribute_reader_example 
    def overwrite attribute_reader_example
    end

    # overwrite attribute_accessor_example writer
    def attribute_accessor_example=(value)
    end
 
    # == description
    # Cause a example_method operation on the screen. 
    #
    # == arguments
    # argument1
    #  Integer
    #    description:  Example argument1
    #    example:    10
    #    default:          
    #  Hash
    #    description:  Example argument 1 type 2
    #    example:  { :optional_1 => "value_1", :optional_2 => "value_2" }
    #    default:
    #
    # argument2
    #  String
    #    description:  Example argument2
    #    example:    "Hello"
    #    default:    
    #
    # == returns
    # String
    #  description:  Return value type
    #   example:    "World"
    # 
    # == exceptions
    # RuntimeError
    #   description:  example exception
    #
    # ArgumentError
    #   description:  example exception
    #    
    # == example
    # example_method( :Down, :Value, { :optional_1 => "value_1", :optional_2 => "value_2" } )
    #
    # == info
    # See method X, table at Y
    #
    def example_method( direction, value = :Value, z = ',', optional_params = {}, y = ',' )
    end

end
