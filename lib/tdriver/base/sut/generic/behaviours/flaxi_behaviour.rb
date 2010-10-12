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
    # == description
    # This module contains implementation to control device flashing
    #
    # == behaviour
    # FlaxiBehaviour
    #
    # == requires
    # *
    # == input_type
    # *
    #
    # == sut_type
    # *
    #
    # == sut_version
    # *
    #
    # == objects
    # sut
    #
    module FlaxiBehaviour

      include MobyBehaviour::Behaviour

      # == description
      # Instructs the sut to start the flash operation with default TDriver parameters for sut that are:
      # <parameter name="flaxi_flash_attempts" value="2" /> <!-- how many times flaxi will attempt to flash the device -->
      # <parameter name="timeout_between_command_sequence" value="25" /> <!-- timeout in seconds between the switchbox commands -->
      # <parameter name="switchbox_commands_before_flash" value="" /> <!-- commands you want to be executed before flash -->
      # <parameter name="flaxi_commands_before_flash" value="" /> <!-- flash command for flaxi before flash -->
      # <parameter name="flaxi_flash_command" value="" /> <!-- intial flash command for flaxi -->
      # <parameter name="timeout_before_executing_commands_during_flash" value="20" /> <!-- timeout in seconds before executing the commands during flash -->
      # <parameter name="switchbox_commands_during_flash" value="" /> <!-- commands you want to be executed during flash -->
      # <parameter name="flaxi_optional_parameters_after_flashing" value="" /> <!-- optional flash parameters -->
      # <parameter name="flaxi_flash_images" value="" /> <!-- images to flash  -->
      # <parameter name="flaxi_sleep_time_after_flash_command" value="70" /> <!-- need to wait for the flash process to finish -->
      # <parameter name="flaxi_command_after_flash" value="" /> <!-- flash command for flaxi after flash -->
      # <parameter name="switchbox_commands_after_failed_flash" value="" /> <!-- commands for switchbox after failed flash -->
      # <parameter name="flaxi_commands_after_failed_flash" value="" /> <!-- commands for flaxi after failed flash -->
      # <parameter name="flaxi_flash_command_success_string" value="" /> <!-- If no error then no string is displayed -->
      # <parameter name="switchbox_commands_after_flash" value="" /> <!-- commands you want to be executed after flash -->
			# == arguments
			# == returns
			# == exceptions
      # BehaviourError
      #  description: If mandatory parameters are missing
			# BehaviourError
      #  description: If flashing is failed
			# === info
      def flash()

        flash_images

      end

      # == description
      # Instructs the sut to start the flash operation with the given software image file:
      # <parameter name="flaxi_flash_attempts" value="2" /> <!-- how many times flaxi will attempt to flash the device -->
      # <parameter name="timeout_between_command_sequence" value="25" /> <!-- timeout in seconds between the switchbox commands -->
      # <parameter name="switchbox_commands_before_flash" value="" /> <!-- commands you want to be executed before flash -->
      # <parameter name="flaxi_commands_before_flash" value="" /> <!-- flash command for flaxi before flash -->
      # <parameter name="flaxi_flash_command" value="" /> <!-- intial flash command for flaxi -->
      # <parameter name="timeout_before_executing_commands_during_flash" value="20" /> <!-- timeout in seconds before executing the commands during flash -->
      # <parameter name="switchbox_commands_during_flash" value="" /> <!-- commands you want to be executed during flash -->
      # <parameter name="flaxi_optional_parameters_after_flashing" value="" /> <!-- optional flash parameters -->
      # <parameter name="flaxi_sleep_time_after_flash_command" value="70" /> <!-- need to wait for the flash process to finish -->
      # <parameter name="flaxi_command_after_flash" value="" /> <!-- flash command for flaxi after flash -->
      # <parameter name="switchbox_commands_after_failed_flash" value="" /> <!-- commands for switchbox after failed flash -->
      # <parameter name="flaxi_commands_after_failed_flash" value="" /> <!-- commands for flaxi after failed flash -->
      # <parameter name="flaxi_flash_command_success_string" value="" /> <!-- If no error then no string is displayed -->
      # <parameter name="switchbox_commands_after_flash" value="" /> <!-- commands you want to be executed after flash -->
			# == arguments
      # flash_files
      #  String
      #  description: The location of the software image file
      #  example: "C:/images/flash_image.img"
			# == returns
			# == raises
      # BehaviourError If mandatory parameters are missing
			# BehaviourError If flashing is failed
			# === examples
			# @sut.flash_images("C:/path/image_file.img")
      def flash_images(flash_files=nil)

        if flash_files==nil
          flash_files=parameter(:flaxi_flash_images)
          Kernel::raise MobyBase::BehaviourError.new("flash_images", "flaxi_flash_images not defined for sut in tdriver_parameters.xml") if flash_files == nil
        end

        str_flaxi_flash_command=parameter(:flaxi_flash_command)
          Kernel::raise MobyBase::BehaviourError.new("flash_images", "flaxi_flash_command not defined for sut in tdriver_parameters.xml") if str_flaxi_flash_command == nil

        str_flaxi_optional_parameters=parameter(:flaxi_optional_parameters_after_flashing)
          Kernel::raise MobyBase::BehaviourError.new("flash_images", "flaxi_optional_parameters_after_flashing not defined for sut in tdriver_parameters.xml") if str_flaxi_optional_parameters == nil

        #build flash command
        flash_command="#{str_flaxi_flash_command} #{flash_files} #{str_flaxi_optional_parameters}"

        #start flashing
        result=start_flashing(flash_command)
        Kernel::raise MobyBase::BehaviourError.new("flash_images", "Flashing failed") if result.to_s == 'false'

      end

      private

      def execute_command_sequence(command_sequence)

        sequence_timeout=parameter(:timeout_between_command_sequence)

        #command sequenc
        str_command=parameter(command_sequence)

        #generate the sequence
        str_command_arr = str_command.split('|')

        #execute command sequence
        str_command_arr.each do |command|
          system(command)
          sleep sequence_timeout.to_i
        end

      end

      def flash_error_recovery()

        #switchbox commands after failed flash
        execute_command_sequence(:switchbox_commands_after_failed_flash)

        #flaxi commands after failed flash
        execute_command_sequence(:flaxi_commands_after_failed_flash)

      end

      def start_flashing(flash_command)

        flaxi_flash_attempts=parameter(:flaxi_flash_attempts)
          Kernel::raise MobyBase::BehaviourError.new("start_flashing", "flaxi_flash_attempts not defined for sut in tdriver_parameters.xml") if flaxi_flash_attempts == nil

        current_flash_attempt=0
        flash_result='false'


        while current_flash_attempt < flaxi_flash_attempts.to_i
          initialize_prommer

          initialize_device
          Thread.new do
            #this intializes the commands that are executed during flash
            wait_timeout=0
            wait_timeout=parameter(:timeout_before_executing_commands_during_flash,10) if parameter(:timeout_before_executing_commands_during_flash)
            sleep wait_timeout.to_i
            #commands executed during flash
            execute_command_sequence(:switchbox_commands_during_flash) if parameter(:switchbox_commands_during_flash)
          end
          flash_result=system(flash_command)
          if flash_result.to_s=='true'
            current_flash_attempt==flaxi_flash_attempts
          else
            flash_error_recovery
          end
          current_flash_attempt+=1
        end

        finalize_prommer

        finalize_device

        flash_result
      end

      # Instructs the SUT to initialize prommer using foobox
      # === params
      # === returns
      # === raises
      def initialize_prommer()

        #switchbox command sequence before flash
        execute_command_sequence(:switchbox_commands_before_flash)

      end

      # Instructs the SUT to initialize device using flaxi
      # === params
      # === returns
      # === raises
      def initialize_device()

        #flaxi command sequence before flash
        execute_command_sequence(:flaxi_commands_before_flash)

      end

      # Instructs the SUT to finalize prommer using foobox
      # === params
      # === returns
      # === raises
      def finalize_prommer()

        #switchbox command sequence before flash
        execute_command_sequence(:switchbox_commands_after_flash)

      end

      # Instructs the SUT to finalize device using flaxi
      # === params
      # === returns
      # === raises
      def finalize_device()

        #flaxi command sequence before flash
        execute_command_sequence(:flaxi_command_after_flash)

      end

	# enable hooking for performance measurement & debug logging
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

    end

end

