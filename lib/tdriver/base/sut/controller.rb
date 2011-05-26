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

    attr_accessor :sut_controllers, :execution_order #, :test_object_adapter, :test_object_factory

    # Creating new SutController associates SutAdapter to the controller
    # == params
    # sut_adapter:: MobyController::SutAdapter descendant, e.g. MobyController::QT::SutAdapter
    # == raises
    # TypeError:: Wrong argument type $1 for SUT controller (expected $2)
    # NameError:: No SUT controller found for %s (%s)
    def initialize( sut_controllers, sut_adapter )

      sut_controllers.check_type String, 'Wrong argument type $1 for SUT controller (expected $2)'

      @sut_adapter = sut_adapter

      # empty sut controllers hash
      @sut_controllers = {}

      # empty sut controller execution order, this will be used when multiple sut controllers given
      @execution_order = []

      sut_controllers.split( ';' ).each{ | sut_type |

        begin

          # add sut_controller to execution order list
          @execution_order << sut_type

          # store sut controller
          @sut_controllers[ sut_type ] = "MobyController::#{ sut_type }"

          # extend controller module
          extend( eval( "#{ @sut_controllers[ sut_type ] }::SutController" ) )

        rescue NameError

          raise MobyBase::ControllerNotFoundError, "No SUT controller found for #{ sut_type } (#{ @sut_controllers[ sut_type ] }::SutController)"

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
    # TypeError:: Wrong argument type $1 for command_data (expected $2)
    # MobyBase::CommandNotFoundError:: if no implementation is found for the CommandData object
    def execute_command( command_data )

      command_data.check_type MobyCommand::CommandData, 'Wrong argument type $1 for command_data (expected $2)'

      # retrieve controller for command; iterate through each sut controller      
      @execution_order.each_with_index do | controller, index |
      
        begin 

          # extend command_data with combinination of corresponding sut specific controller  
          command_data.extend eval("#{ @sut_controllers[ controller ] }::#{ command_data.class.name.gsub(/^MobyCommand::/, '') }")
          
          break
        
        rescue NameError
                
          # raise exception only if none controller found
          if ( index + 1 ) == @execution_order.count

            raise MobyBase::ControllerNotFoundError, "No controller found for command data object #{ command_data.inspect }"

          end

        end
      
      end

      # pass sut_adapter for command_data
      command_data.set_adapter( @sut_adapter )

      retries = 0

      begin 

        # execute the command
        command_data.execute

      rescue Errno::EPIPE, IOError

        raise if retries == 1

        retries += 1

        if MobyBase::SUTFactory.instance.connected_suts.include?( @sut_adapter.sut_id.to_sym )

          @sut_adapter.disconnect

          @sut_adapter.connect( @sut_adapter.sut_id )

        end

        retry
        
      end
      
    end # execute_command

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # SutController

end # MobyBase
