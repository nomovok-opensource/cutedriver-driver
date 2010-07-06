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

# generated behaviour implementation
module MobyBehaviour

	# == description
	# This module contains example implementation containing tags for documentation generation  
	#
	# == behaviour
	# QtExampleBehaviour
	#
	# == requires
	# testability-driver-sut-qt-plugin
	#
	# == input_type
	# *
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
	module Example

		include MobyBehaviour::Behaviour

	private # construction

		# this method will be called once module is extended to test object	
		def self.extended( object )

			object.instance_exec{

				# default settings (optional)
				initialize_behaviour_settings

			}

		end
	
		# this method will be called once behaviour is extended to test object
		def initialize_behaviour_settings

		end

	public # behaviours

		# TODO: jotain
		# this line won't be documented
		#
		# == description
		# Cause a drag operation on the screen. Basically the same as flick or gesture but done slowly.
		#
		# == arguments
		# direction
		#	type: 		String 
		#	description:	Angle of direction of the drag. Supported range is from 0 to 360
		#	example: 	180 
		#	default: 	
		#
		# direction
		# 	type: 		Symbol 
		#	description:	Symbol of direction of the drag. See Valid drag direction symbols table for valid values.
		#	example:	:Right
		#	default: 	:Left
		#
		# distance
		#	type:		Integer
		#	description:	Distance in pixels of the drag motion
		#	example:	10
		#	default:
		#
		# button
		#	type:		Symbol
		#	description:	Symbol of button used for drag. See Valid drag button symbols table for valid values.
		#	example:	:Left
		#	default:	:Left
		#
		# == returns
		# MobyBase::TestObject
		#	description:	Target test object
		# 	example:
		# 
		# MobyBase::TestObject2
		# 	description:	Target test object2
		# 	example:	example2
		#
		# == exceptions
		# MobyBase::TestObjectNotFoundError
		# 	description:	If a graphics item is not visible on screen
		#			lisäää descriptionia
		#
		# ArgumentError
		# 	description:	If an invalid direction or button is given
		#		
		# == example
		# # Drag QGraphicsItem with tooltip 'node1' down 50 pixels
    		# @sut.application.GraphWidget.QGraphicsItem(:tooltip => 'node1').drag(:Down, 50)
		#
		# # Drag 'test_object' up 200 pixels
		# @test_object = @sut.application.GraphWidget.QGraphicsItem(:tooltip => 'node1')
    		# @test_object.drag(:Up, 200)
		#
		# == see
		# flick, gesture
		def drag( direction, distance, button = :Left )

			# implementation

		end

		# documentation for the method
		def []=( value )

			# implementation

		end

		# documentation for the method
		def []( value )

			# implementation

		end

		# documentation for the method
		def d

			# implementation

		end

		# documentation for the method
		def <=>( other )

			# implementation

		end

		# documentation for the method
		def e()

			# implementation

		end

		# documentation for the method
		def f!()

			# implementation

		end

		# documentation for the method
		def g?()

			# implementation

		end

		# documentation for the method
		def x# dada

			# implementation

		end

		attr_accessor :xxz

		attr_reader :yys

	end # Example

end # MobyBehaviour
