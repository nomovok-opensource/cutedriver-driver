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


# Find behaviour 
# Methods for finding test objects on the suttest objet state
module MobyBehaviour

	# Defines methods to find test objects and scroll them to the display
	module Find   

		include MobyBehaviour::Behaviour

		# Finds a child test_object given its name and type and returns it as a reference 
		# === params
		# find_hash:: Hash with one or more attributes defining the rules for the test object search
		# === returns
		# TestObject:: A reference to the found test object
		# === raises
		# TypeError:: This exception will be thrown if input is not of type Hash or Hash is empty
		# MobyBase::TestObjectNotFoundError This exception will be thrown when no test object with the attributes provided in the arguments is found in the SUT
		# MobyBase::MultipleTestObjectsIdentifiedError This exception will be thrown when multiple test objects with the attributes provided in the arguments are found in the SUT
		# === examples
		#  @sut.find(:type => Button, :name => 'ClearAll')
		def find ( find_hash = {} )

			begin

				raise TypeError.new( 'Input parameter not of Type: Hash or empty.\nIt is: ' + find_hash.class.to_s ) unless find_hash.kind_of?( Hash ) and !find_hash.empty?

				search_result = child(find_hash)

			rescue Exception => e

				MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to find test object.;#{id.to_s};sut;{};find;" << ( find_hash.kind_of?( Hash ) ? find_hash.inspect : find_hash.class.to_s )

				Kernel::raise e

			end

			MobyUtil::Logger.instance.log "behaviour" , "PASS;Test object found.;#{id.to_s};sut;{};application;" << find_hash.inspect 

			search_result
		end

		### Finds a child test_object given its name and type, centers it to the screen and returns it as a reference 
		### === params
		### find_hash:: Hash with one or more attributes defining the rules for the test object search
		### === returns
		### TestObject:: A reference to the found test object
		### === raises
		### TypeError:: This exception will be thrown if input is not of type Hash or Hash is empty
		### MobyBase::TestObjectNotFoundError This exception will be thrown when no test object with the attributes provided in the arguments is found in the SUT
		### MobyBase::MultipleTestObjectsIdentifiedError This exception will be thrown when multiple test objects with the attributes provided in the arguments are found in the SUT
		### === examples
		###  @sut.find_and_center(:type => Button, :name => 'ClearAll')
		# def find_and_center (find_hash = {})
		# begin
		# search_result = find(find_hash)
		### Calculate Center
		#### WORKS ONLY IN QC TESTAPP!! (for now)
		### window_width = search_result.sut.application.NodeView.attribute('width').to_i/2
		### window_height = search_result.sut.application.NodeView.attribute('height').to_i/2
		### window_x = search_result.sut.application.NodeView.attribute('x_absolute').to_i + window_width.to_i
		### window_y = search_result.sut.application.NodeView.attribute('y_absolute').to_i + window_height.to_i

		### window_width = search_result.sut.application.MainWindow.attribute('width').to_i/2
		### window_height = search_result.sut.application.MainWindow.attribute('height').to_i/2
		### window_x = search_result.sut.application.MainWindow.attribute('x_absolute').to_i + window_width.to_i
		### window_y = search_result.sut.application.MainWindow.attribute('y_absolute').to_i + window_height.to_i

		# myWindow = search_result.sut.application.find(:isWindow => "true").first # throws multiple found exeptions
		# window_width = myWindow.attribute('width').to_i/2
		# window_height = myWindow.attribute('height').to_i/2
		# window_x = myWindow.attribute('x_absolute').to_i + window_width.to_i
		# window_y = myWindow.attribute('y_absolute').to_i + window_height.to_i

		### flick_to (center)
		# search_result.flick_to(window_x.to_i, window_y.to_i)
		# rescue Exception => e
		###MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to find test object.;#{id.to_s};sut;{};find;" << (find_hash.kind_of?(Hash) ? find_hash.inspect : find_hash.class.to_s)  
		### Rescue from center and flick
		# Kernel::raise e
		# end
		# MobyUtil::Logger.instance.log "behaviour" , "PASS;Test object found and centered.;#{id.to_s};sut;{};application;" << find_hash.inspect  
		# search_result
		# end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # Find

end # MobyBehaviour
