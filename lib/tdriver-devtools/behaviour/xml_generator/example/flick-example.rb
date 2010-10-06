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

  module QT

    # == description
    # This module contains demonstration implementation containing tags for documentation generation using gesture as an example
    #
    # == behaviour
    # QtExampleGestureBehaviour
    #
    # == requires
    # *
    # == input_type
    # touch
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # *;sut
    #
    module Gesture

      # == description
      # example desc
      #
      # == returns
      # String
      #  description: Return value type
      #  example: "World"
      # == arguments
      # value
      #  Integer
      #   description: Example argument1
      #   example: 10
      attr_accessor :z
   
      # == description
      # Cause a flick operation on the screen. 
      #
      # == arguments
      # direction
      #  Integer
      #   description: Example argument1
      #   example: 10
      #  Hash
      #   description:
      #    Example argument 1 type 2
      #   example: { :optional_1 => "value_1", :optional_2 => "value_2" }
      #
      # button
      #  String
      #   description: which button to use
      #   example: "Hello"
      #   default: :Left
      #
      # optional_params
      #  String
      #   description: optinal parameters for blaa blaa blaa
      #   example: {:a => 1, :b => 2}
      #   default: {}
      #
      # == returns
      # String
      #  description: Return value type
      #  example: "World"
      # 
      # == exceptions
      # RuntimeError
      #  description:  example exception
      #
      # ArgumentError
      #  description:  example exception
      #    
      # == tables
      # custom1
      #  title: Custom table1
      #  |hdr1|hrd2|hrd2|
      #  |1.1|1.2|1.3|
      #  |2.1|2.2|2.3|
      # 
      # custom2
      #  title: Custom table2
      #  |id|value|
      #  |0|true|
      #  |1|false|
      # == info
      # See method X, table at Y
      #
      def flick( direction, button = :Left, optional_params = {} )
      begin
          nil
      end


    end

  end
end

#MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Gesture )
