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

module MobyUtil

  class Scripter

    def initialize(sut_id, object_identificators)

      @_object_identificators = object_identificators

      @_tap_max_time = $parameters[sut_id][:record_tap_time_treshold].to_i
      @_tap_min_distance = $parameters[sut_id][:record_move_treshold].to_i

    end

    def write_fragment(xml_as_object, app_name)
    
      script =  "# Insert the script fragment below into your test \n"
      script << "# Add verification points if needed. \n \n"
      script << "# For testing the script! Do not include in your own test scripts. \n"
      script << "@app = sut.application(:name =>'" << app_name << "') \n"  
      script << "# To test the script make sure the application is in the same state as it was when recording was started. \n\n"
      script << "#################################### \n"
      script << "# Begin recorded script              \n"
      script << "#################################### \n \n"

      event_list = xml_as_object.events
      event_count = event_list.attribute('eventCount').to_i

      mouse_down = false
      points = Array.new
      active_target = nil
      scripting = false;
      mouse_status = 0
      previous_time = nil
      event = nil
      
      # puts "START mouse Down events"
      ##mouse_events = xml_as_object.children(:type =>'event', :name=>'MouseButtonPress')
      #mouse_events = xml_as_object.children(:type =>'event', :name=>'MouseMove')
      # puts mouse_events.length.to_s
      #mouse_events.each do |point|
      #  puts " #{point.id} [ #{point.attribute('windowX')}, #{point.attribute('windowX')} ]"
      #end
      # puts "END mouse Down events"
      
      
      # mouse_status: 
      # 0 = no press or release
      # 1 = press, no release     [ will only happen if recording stoped before mouse release]
      # 2 = release, no press     [ will only happen if recording started after mouse press]
      # 3 = press and release
      
      # COLLECT ALL MOUSE EVENTS
      mouse_moves = xml_as_object.children(:type =>'event', :name=>'MouseMove')
      mouse_press_events = xml_as_object.children(:type =>'event', :name=>'MouseButtonPress')
      mouse_release_events = xml_as_object.children(:type =>'event', :name=>'MouseButtonRelease')
      
      # STORE MOVE POINTS
      move_points = []
      mouse_moves.each do |point|
        timestamp = point.attribute('timeStamp').to_i
        previous_timestamp = ( move_points[-1].nil? ) ? timestamp : move_points[-1]['timestamp'].to_i
        interval = get_duration(previous_timestamp, timestamp)
        move_points.push({'x' => point.attribute('windowX'), 'y' => point.attribute('windowY'), 'interval' => interval, 'timestamp' => timestamp, 'id' => point.id} )
      end
      
      # STORE RELEASE EVENTS
      release_events = []
      mouse_release_events.each do |event|
        release_events.push({'id' => event.id})
      end

      # FOREACH MouseButtonPress
      mouse_press_events.each_index do |index|
        active_target = get_target_details( mouse_press_events[index].child(:id => mouse_press_events[index].id) )  

        # COLLECT MouseMove points until MouseButtonRelease
        # If no more MouseButtonRelease or MouseButtonPress then last MoveMouse point id
        first_point_index = mouse_press_events[index].id.to_i
        next_mouse_press_index =  ( mouse_press_events[ index + 1 ].nil? ) ?  move_points.last['id'].to_i : mouse_press_events[ index + 1 ].id.to_i
        next_mouse_release_index = release_events.select{ |event| event['id'].to_i < next_mouse_press_index }.first['id'].to_i
        last_point_index = ( next_mouse_release_index.nil? ) ? next_mouse_press_index : next_mouse_release_index
        
        points = move_points.select{ |point| point['id'].to_i > first_point_index and point['id'].to_i <= last_point_index }
        points.first['interval'] = 0.to_f unless points.empty? # set first interval to 0
        
        # PROCESS gesture at MouseButtonRelease
        if ( last_point_index != move_points.last['id'].to_i )
          script << generate_command(active_target, points, mouse_status = 3 ) << "\n"   
          
        # END EVENTS, MouseButtonRelease truncated or second press without release witch would not make sense
        else
          script << generate_command(active_target, points, mouse_status = 1 ) << "\n"  
        end
        
      end
      


      # for i in 0...event_count
        
        # event = event_list.event(:id => i.to_s)
        # type = event.name
        
        # previous_time = event.attribute('timeStamp').to_i unless previous_time

        # if type == 'MouseButtonPress'
          # active_target = get_target_details(event.child(:id => i.to_s))      
          # scripting = true
          # mouse_status = 1
        # end
        
        # duration = get_duration(previous_time, event.attribute('timeStamp').to_i)
        
        # point = {'x' => event.attribute('windowX'), 'y' => event.attribute('windowY'), 'interval' => duration}
        # points.push(point) if scripting 
        
        # previous_time = event.attribute('timeStamp').to_i

        # if type == 'MouseButtonRelease' and scripting

          ##mouse status based on the previous (if target changed no press)
          # mouse_status = 3 if mouse_status == 1
          # mouse_status = 2 if mouse_status == 0    
          # script << generate_command(active_target, points, mouse_status) << "\n"      
          # points.clear
          # active_target = nil
          # scripting = false

        # end
      # end  

      # if scripting and event

        # script << generate_command(active_target, points, mouse_status) << "\n"

      # end

      script << "\n"
      script << "#################################### \n"
      script << "# End recorded script                \n"
      script << "#################################### \n"
      script     

    end

  private

    def add_command( mouse_status, active_target, points, duration )

      fragment << fragment

    end

    def get_target_details(test_object)

      target = test_object.type
      params = Array.new

      params.push(":name=>'#{ test_object.name }'") 

      if test_object.name.empty?

        params.clear

        @_object_identificators.each do |attribute|

          begin

            value = test_object.attribute(attribute)
            params.push(":#{ attribute } => '#{ value }'") unless value == "" 

          rescue MobyBase::AttributeNotFoundError

          end

        end

      end

      if params.size > 0

        target << "( "

        until params.size == 0

          target << params.pop
          target << ", " if params.size > 0

        end

        target << " )"

      end

      target
    end

    # mouse_status: 
    # 0 = no press or release
    # 1 = press, no release
    # 2 = release, no press
    # 3 = press and release
    def generate_command(target_details, points, mouse_status)

      command = "@app." 

      if valid_gesture?(points)

        command << target_details << ".gesture_points(\n\t[\n"
        duration = 0 

        for i in 0...points.size  

          value =  points[ i ]
          command << "\t\t{'x' => " << value[ "x" ].to_s << ", 'y' => " << value[ "y" ].to_s << ", 'interval' => " << value[ "interval" ].to_s << " }"
          command << ", \n" unless i == points.size - 1
          duration = duration + value[ 'interval' ]

        end

        command << "\n\t], \n\t" << duration.to_s << ", \n\t"

        case mouse_status
          when 0
            command << "{ :press => false, :release => false }"
          when 1
            command << "{ :press => true, :release => false }"
          when 2
            command << "{ :press => false, :release => true }"
          when 3
            command << "{ :press => true, :release => true }"
        end

        command << "\n)"

        command

      elsif mouse_status > 0

        duration = 0

        points.each{|value| duration = duration + value['interval']}

        if mouse_status == 1

          command << target_details << ".tap_down" 

        elsif duration < @_tap_max_time

          command << target_details << ".tap" 

        else

          command << target_details << ".long_tap( " << duration.to_s << " )" 

        end

      end
    end

    def valid_gesture?(points)

      return false if points.size < 2

      min_x = -1
      max_x = -1
      min_y = -1
      max_y = -1

      for i in 0...points.size  

        value =  points[i]

        x = value['x'].to_i
        y = value['y'].to_i

        min_x = x if x < min_x or min_x == -1
        max_x = x if x > max_x or max_x == -1
        min_y = y if y < min_y or min_y == -1
        max_y = y if y > max_y or max_y == -1

      end

      return false if (max_x - min_x).abs < @_tap_min_distance and (max_y - min_y).abs < @_tap_min_distance
      
      true
    end

    def get_duration(start_time, end_time)
      duration_millis = end_time - start_time
      #we want this in second
      duration_millis = duration_millis.to_f
      duration_secs = duration_millis / 1000
      duration_secs
    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # Scripter

end # MobyUtil
