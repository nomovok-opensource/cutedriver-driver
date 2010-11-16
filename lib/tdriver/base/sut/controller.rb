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

module MobyBase

	class SutController

		attr_accessor :sut_controllers, :execution_order

		# Creating new SutController associates SutAdapter to the controller
		# == params
		# sut_adapter:: MobyController::SutAdapter descendant, e.g. MobyController::QT::SutAdapter
		# == raises
    # TypeError:: Wrong argument type $1 for SUT controller (Expecting $2)
		# NameError:: No SUT controller found for %s (%s)
		def initialize( sut_controllers, sut_adapter )

      sut_controllers.check_type( String, "Wrong argument type $1 for SUT controller (Expecting $2)" )

			@sut_adapter = sut_adapter

			# empty sut controllers hash
			@sut_controllers = {}

			# empty sut controller execution order, this will be used when multiple sut controllers given
			@execution_order = []

			sut_controllers.split(";").each{ | sut_controller |

				begin

					# controller module to extend
					controller_module = eval( ( module_name = "MobyController::#{ sut_controller }::SutController" ) )

					# add sut_controller to execution order list
					@execution_order << sut_controller

					# store controller module to cache
					@sut_controllers[ sut_controller ] = module_name.scan( /(.+)::/ )

					# extend required controller behaviour
					self.extend controller_module

				rescue NameError

					Kernel::raise MobyBase::ControllerNotFoundError.new( 'No SUT controller found for %s (%s)' % [ sut_controller, module_name ] )

				end

			}

		end

		# Function to execute a command on a SutController
		# This method is not meant to be overwritten in descendants.
		#
		# Associates MobyCommand::CommandData implementation based on the MobyCommand class name,
		# by finding implementation from the same module as the SutController instance. 
		#
		# example: MobyController::QT::SutController instance associates MobyController::QT::Application (module)
		# implementation to MobyCommand::Application command_data object
		#
		# == params
		# command_data:: MobyCommand::CommandData descendant
		# == returns
		# command_data implementation specific return value
		# == raises
		# TypeError:: Wrong argument type $1 for command_data (Expecting $2)
		# MobyBase::CommandNotFoundError:: if no implementation is found for the CommandData object
		def execute_command( command_data )

      command_data.check_type( MobyCommand::CommandData, "Wrong argument type $1 for command_data (Expecting $2)" )

			@execution_order.each{ | controller |

				begin 

					# extend command_data with combinination of command data object name and module name to be extended  
					eval 'command_data.extend %s::%s' % [ @sut_controllers[ controller ], command_data.class.name.scan( /::(.+)/ ) ]

					# break if controller associated succesfully 
					break

				rescue NameError

					# raise exception only if none controller found
					Kernel::raise MobyBase::ControllerNotFoundError.new( 'No controller found for CommandData object %s' % command_data.inspect ) unless controller.object_id != @execution_order.last.object_id
				end

			}
			
			command_data.set_adapter( @sut_adapter )      
			command_data.execute

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


	end # SutController

end # MobyBase
