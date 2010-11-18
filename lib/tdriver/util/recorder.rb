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
 
# Class for recording scripts from qt applications.
# Complete test script recording not supported. 
# Application must be running when recording is started and 
# must not be closed as a during the recording.

module MobyUtil

	class Recorder

		#TODO detect app start for later versions...
		def self.start_rec( app )

			#Kernel::raise ArgumentError.new("Application must be defined.") unless app
			app.check_type( MobyBase::TestObject, "Wrong argument type $1 for application object (expected $2)" )

			app.start_recording

		end

		# Prints the recorded events as an tdriver script fragment.
		def self.print_script( sut, app, object_identificators = ['text','icontext','label'] )

      # verify that sut type is type of MobyBase::SUT
			#Kernel::raise ArgumentError.new("Sut must be defined.") unless sut
      sut.check_type( MobyBase::SUT, "Wrong argument type $1 for SUT (expected $2)" )

			#Kernel::raise ArgumentError.new("Application must be defined.") unless app
      app.check_type( MobyBase::TestObject, "Wrong argument type $1 for application object (expected $2)" )

			#Kernel::raise ArgumentError.new("Object identificators must be set, use defaults if not sure what the use.") unless object_identificators
      object_identificators.check_type( Array, "Wrong argument type $1 for object identificators (expected $2)" )
      
			xml_source = app.print_recordings

			app.stop_recording
			
			Scripter.new( sut.id, object_identificators ).write_fragment( MobyBase::StateObject.new( xml_source ), app.name )

		end


	end # Recorder

	class Scripter

		def initialize(sut_id, object_identificators)

			@_object_identificators = object_identificators

			@_tap_max_time = Parameter[sut_id][:record_tap_time_treshold].to_i
			@_tap_min_distance = Parameter[sut_id][:record_move_treshold].to_i

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

			for i in 0...event_count

				event = event_list.event(:id => i.to_s)
				type = event.name

				previous_time = event.attribute('timeStamp').to_i unless previous_time

				if type == 'MouseButtonPress'
					active_target = get_target_details(event.child(:id => i.to_s))		  
					scripting = true
					mouse_status = 1
				end

				duration = get_duration(previous_time, event.attribute('timeStamp').to_i)

				point = {'x' => event.attribute('windowX'), 'y' => event.attribute('windowY'), 'interval' => duration}
				points.push(point) if scripting 

				previous_time = event.attribute('timeStamp').to_i

				if type == 'MouseButtonRelease' and scripting

					#mouse status based on the previous (if target changed no press)
					mouse_status = 3 if mouse_status == 1
					mouse_status = 2 if mouse_status == 0	  
					script << generate_command(active_target, points, mouse_status) << "\n"  	  
					points.clear
					active_target = nil
					scripting = false

				end
			end	

			if scripting and event

				script << generate_command(active_target, points, mouse_status) << "\n"

			end

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

	end # Scripter

end
