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
    # testability-driver-sut-qt-plugin
    #
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

    include MobyBehaviour::QT::Behaviour
      
    # == description
    # Cause a flick operation on the screen. 
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
    # flick( :Down, :Left, { :optional_1 => "value_1", :optional_2 => "value_2" } )
    #
    # == info
    # See method X, table at Y
    #
    # == howto
    # Example1
    #   description: Basic use
    #  code: @sut = TDriver.sut( :Id => "sut_qt" )
    #    app = @sut.application
    #    app.QPushButton( :text => "Close" ).flick :Left
    #
    def flick( direction, button = :Left, optional_params = {} )
    end

    private

      # Performs the actual gesture operation. 
      # Verifies that the parameters are correct and send the command
      # to the sut. 
      # gesture_type: :MouseGesture, :MouseGestureTo, :MouseGestureToCoordinates
      # params = {:direction => :Up, duration => 2, :distance =>100, :isDrag =>false, :isMove =>false }
      def do_gesture(params)
      end

      def do_sleep(time)
      end

      def calculate_speed(distance, speed)
      end

      def distance_to_point(x, y)
      end

    end

  end

end
