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

    #include MobyBehaviour::QT::Behaviour
      
    attr_accessor :x
    attr_reader :y
    attr_writer :z

    def y
    
    end

    def x=(value)
    end
 
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
    def flick( direction, button = :Left, z = ',', optional_params = {}, y = ',' )
    begin
          use_tap_screen = optional_params[:use_tap_screen].nil? ? MobyUtil::Parameter[ @sut.id][ :use_tap_screen, 'false'] :
            optional_params[:use_tap_screen].to_s
          optional_params[:useTapScreen] = use_tap_screen
          
          speed = calculate_speed(@sut.parameter(:gesture_flick_distance), @sut.parameter(:gesture_flick_speed))
          distance = @sut.parameter(:gesture_flick_distance).to_i
          params = {:gesture_type => :MouseGesture, :direction => direction, :speed => speed, :distance => distance, :isDrag => false, :button => button, :useTapScreen => use_tap_screen}
          params.merge!(optional_params)
     
          do_gesture(params)    
          do_sleep(speed)
           
        rescue Exception => e

          MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed flick with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"
          Kernel::raise e        
        end      
 
        MobyUtil::Logger.instance.log "behaviour" , "PASS;Operation flick executed successfully with direction \"#{direction}\", button \"#{button.to_s}\".;#{identity};flick;"

        nil
      end


    private

      # Performs the actual gesture operation. 
      # Verifies that the parameters are correct and send the command
      # to the sut. 
      # gesture_type: :MouseGesture, :MouseGestureTo, :MouseGestureToCoordinates
      # params = {:direction => :Up, duration => 2, :distance =>100, :isDrag =>false, :isMove =>false }
      def do_gesture(params)
          validate_gesture_params!(params)

          if attribute('objectType') == 'Embedded'
          params['x'] = center_x
          params['y'] = center_y          
          params['useCoordinates'] = 'true'
          end

        command = command_params #in qt_behaviour           
        command.command_name(params[:gesture_type].to_s)
        command.command_params( params )
        @sut.execute_command( command )
      end

      def validate_gesture_params!(params)
        #direction    
        if params[:gesture_type] == :MouseGesture
        if params[:direction].kind_of?(Integer)
          raise ArgumentError.new( "Invalid direction." ) unless 0 <= params[:direction].to_i and params[:direction].to_i <= 360 
        else
          raise ArgumentError.new( "Invalid direction." ) unless @@_valid_directions.include?(params[:direction])  
          params[:direction] = @@_direction_map[params[:direction]]
        end
        #distance
        params[:distance] = params[:distance].to_i unless params[:distance].kind_of?(Integer)
        raise ArgumentError.new( "Distance must be an integer and greater than zero." ) unless  params[:distance] > 0
        elsif params[:gesture_type] == :MouseGestureToCoordinates
        raise ArgumentError.new("X and Y must be integers.") unless params[:x].kind_of?(Integer) and params[:y].kind_of?(Integer)
        elsif params[:gesture_type] == :MouseGestureTo
        raise ArgumentError.new("targetId and targetType must be defined.") unless params[:targetId] and params[:targetType]
        end        

        #duration/speed 
        params[:speed] = params[:speed].to_f unless params[:speed].kind_of?(Numeric)
        raise ArgumentError.new( "Duration must be a number and greated than zero, was:" + params[:speed].to_s) unless params[:speed] > 0
        duration_secs = params[:speed].to_f
        duration_secs = duration_secs*1000
        params[:speed] = duration_secs.to_i

        #mouseMove true always
        params[:mouseMove] = true

        params[:button] = :Left unless params[:button]
        raise ArgumentError.new( "Invalid button." ) unless @@_valid_buttons.include?(params[:button])
        params[:button] = @@_buttons_map[params[:button]]

        if params[:isMove] == true
        params[:press] = 'false'
        params[:release] = 'false'
        end

      end


      def do_sleep(time)

        if MobyUtil::Parameter[ @sut.id ][ :sleep_disabled, nil ] != 'true'
        time = time.to_f
        time = time * 1.3
        #for flicks the duration of the gesture is short but animation (scroll etc..) may not
        #so wait at least one second
        time = 1 if time < 1  
        sleep time
        end

      end

      def calculate_speed(distance, speed)

        distance = distance.to_f
        speed = speed.to_f
        duration = distance/speed
        duration

      end

      def distance_to_point(x, y)

        x = x.to_i
        y = y.to_i
        dist_x = x - center_x.to_i
        dist_y = y - center_y.to_i

        return 0 if dist_y == 0 and dist_x == 0     
        distance = Math.hypot( dist_x, dist_y )
        distance

      end

    end

  end
end

#MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Gesture )
