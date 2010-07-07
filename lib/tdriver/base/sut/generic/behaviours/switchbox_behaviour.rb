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

module MobyBehaviour
  
    module SwitchboxBehaviour
      include MobyBehaviour::Behaviour

      # Instructs the SUT to reboot
      # === params
      # === returns
      # === raises
      def reset
        str_sleep_time_before_powerup = parameter(:switchbox_sleep_before_powerup_in_reboot)
        Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_before_powerup_in_reboot not defined for sut in tdriver_parameters.xml") if str_sleep_time_before_powerup == nil

        str_sleep_time_after_powerup = parameter(:switchbox_sleep_after_powerup_in_reboot)
        Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_after_powerup_in_reboot not defined for sut in tdriver_parameters.xml") if str_sleep_time_after_powerup == nil

        str_commands_after_powerup = parameter(:switchbox_commands_after_powerup_in_reboot)

        begin
          sleep_time_before_powerup = str_sleep_time_before_powerup.to_i
          Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_before_powerup_in_reboot need to be non-negative integer smaller than 50 seconds") if sleep_time_before_powerup < 0 or sleep_time_before_powerup > 50

        rescue
          Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_in_reboot could not be converted to integer")
        end

        begin
          sleep_time_after_powerup = str_sleep_time_after_powerup.to_i
          Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_after_powerup_in_reboot need to be non-negative integer smaller than 500 seconds") if sleep_time_after_powerup < 0 or sleep_time_after_powerup > 500

        rescue
          Kernel::raise BehaviourError.new("reboot", "switchbox_sleep_after_powerup_in_reboot could not be converted to integer")
        end

        
        
        power_down
        begin
          disconnect
        rescue
        end
        sleep sleep_time_before_powerup
        power_up
        sleep sleep_time_after_powerup

        MobyUtil::Retryable.until( :timeout => 60, :retry_timeout => 5 ) {
					system(str_commands_after_powerup) if str_commands_after_powerup != nil
					self.connect(self.id) if MobyUtil::Parameter[ :ats4_error_recovery_enabled, false ]=='true'
				}
      end

      # Instructs the switchbox to power down the sut
      # === params
      # === returns
      # === raises
      def power_down
        str_command_arr = []

        str_command = parameter(:switchbox_powerdown_command_sequence)

        switchbox_sequence_timeout = parameter(:switchbox_timeout_between_command_sequence)

        Kernel::raise BehaviourError.new("power_down", "switchbox_timeout_between_command_sequence not defined for sut in tdriver_parameters.xml") if switchbox_sequence_timeout == nil

        Kernel::raise BehaviourError.new("power_down", "switchbox_powerdown_command not defined for sut in tdriver_parameters.xml") if str_command == nil

        str_result = parameter(:switchbox_powerdown_command_success_string)
        Kernel::raise BehaviourError.new("power_down", "switchbox_powerdown_command_success string not defined for sut in tdriver_parameters.xml") if str_result == nil

        #generate the sequence
        str_command_arr = str_command.split('|')

        #execute switchbox command
        str_command_arr.each do |foobox_command|
          std_out = system(foobox_command)
          sleep switchbox_sequence_timeout.to_i
          Kernel::raise BehaviourError.new("power_down", "Failed to power down") unless std_out.to_s.downcase.include?(str_result.to_s.downcase)
        end
        @switch_box_power_status = false
      end

      # Instructs the switchbox to power up the sut
      # === params
      # === returns
      # === raises
      def power_up
        str_command_arr = []

        switchbox_sequence_timeout = parameter(:switchbox_timeout_between_command_sequence)

        Kernel::raise BehaviourError.new("power_down", "switchbox_timeout_between_command_sequence not defined for sut in tdriver_parameters.xml") if switchbox_sequence_timeout == nil

        str_command = parameter(:switchbox_powerup_command_sequence)
        Kernel::raise BehaviourError.new("power_up", "switchbox_powerup_command not defined for sut in tdriver_parameters.xml") if str_command == nil

        str_result = parameter(:switchbox_powerup_command_success_string)
        Kernel::raise BehaviourError.new("power_up", "switchbox_powerup_command_success string not defined for sut in tdriver_parameters.xml") if str_result == nil

        #generate the sequence
        str_command_arr = str_command.split('|')

        #execute switchbox command
        str_command_arr.each do |foobox_command|
          std_out = system(foobox_command)
          sleep switchbox_sequence_timeout.to_i
          Kernel::raise BehaviourError.new("power_up", "Failed to power up") unless std_out.to_s.downcase.include?(str_result.to_s.downcase)
        end

        @switch_box_power_status = true
      end

    end

    # Gets the current power status of the switchbox
    # === params
    # === returns
    # === raises
    def power_status
      if @switch_box_power_status == nil
        false
      else
        @switch_box_power_status
      end
    end

	# enable hooking for performance measurement & debug logging
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


end
