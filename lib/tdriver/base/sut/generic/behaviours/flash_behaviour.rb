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
  # GenericFlashBehaviour
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
  module FlashBehaviour

    include MobyBehaviour::Behaviour

    # == description
    # Instructs the sut to start the flash operation with default TDriver parameters  
    #
    #
    # == arguments
    # == returns
    # Boolean
    #  description: Indicating that did flashing success
    #  example: true
    # == exceptions
    # BehaviourError
    #  description: If mandatory parameters are missing
    # BehaviourError
    #  description: If flashing is failed
    #
    # == tables
    # flash_prameters
    #  title: Flash parameters
    #  description: Flash parameters for sut
    #  |Parameter|Description|Example|
    #  |:flash_attempts|How many times TDriver will attempt to flash the device|<parameter name="flash_attempts" value="2" />|
    #  |:timeout_between_command_sequence|Timeout in seconds between the switchbox commands|<parameter name="timeout_between_command_sequence" value="25" />|
    #  |:switchbox_commands_before_flash|Commands you want to be executed before flash|<parameter name="switchbox_commands_before_flash" value="" />|
    #  |:commands_before_flash|Flash commands before flash|<parameter name="commands_before_flash" value="" />|
    #  |:flash_command|Intial flash command|<parameter name="flash_command" value="" />|
    #  |:timeout_before_executing_commands_during_flash|Timeout in seconds before executing the commands during flash|<parameter name="timeout_before_executing_commands_during_flash" value="20" />|
    #  |:switchbox_commands_during_flash|Commands you want to be executed during flash|<parameter name="switchbox_commands_during_flash" value="" />|
    #  |:optional_parameters_after_flashing|Optional flash parameters|<parameter name="optional_parameters_after_flashing" value="" />|
    #  |:flash_images|Images to flash|<parameter name="flash_images" value="" />|
    #  |:sleep_time_after_flash_command|Wait time for the flash process to finish|<parameter name="sleep_time_after_flash_command" value="70" />|
    #  |:command_after_flash|Flash command after flash|<parameter name="command_after_flash" value="" />|
    #  |:switchbox_commands_after_failed_flash|Commands for switchbox after failed flash|<parameter name="switchbox_commands_after_failed_flash" value="" />|
    #  |:commands_after_failed_flash|Commands after failed flash|<parameter name="commands_after_failed_flash" value="" />|
    #  |:flash_command_success_string|If no error then no string is displayed|<parameter name="flash_command_success_string" value="" />|
    #  |:switchbox_commands_after_flash|Commands you want to be executed after flash|<parameter name="switchbox_commands_after_flash" value="" />|

    def flash()

      flash_images

    end

    # == description
    # Instructs the sut to start the flash operation with the configured flash files
    #
    # == arguments
    # flash_files
    #  String
    #  description: The location of the software image file
    #  example: "C:/images/flash_image.img"
    # == returns
    # Boolean
    #  description: Indicating that did flashing success
    #  example: true
    # == raises
    # BehaviourError If mandatory parameters are missing
    # BehaviourError If flashing is failed
    # === examples
    # @sut.flash_images("C:/path/image_file.img")
    # == tables
    # flash_prameters
    #  title: Flash parameters
    #  description: Flash parameters for sut
    #  |Parameter|Description|Example|
    #  |:flash_attempts|How many times TDriver will attempt to flash the device|<parameter name="flash_attempts" value="2" />|
    #  |:timeout_between_command_sequence|Timeout in seconds between the switchbox commands|<parameter name="timeout_between_command_sequence" value="25" />|
    #  |:switchbox_commands_before_flash|Commands you want to be executed before flash|<parameter name="switchbox_commands_before_flash" value="" />|
    #  |:commands_before_flash|Flash commands before flash|<parameter name="commands_before_flash" value="" />|
    #  |:flash_command|Intial flash command|<parameter name="flash_command" value="" />|
    #  |:timeout_before_executing_commands_during_flash|Timeout in seconds before executing the commands during flash|<parameter name="timeout_before_executing_commands_during_flash" value="20" />|
    #  |:switchbox_commands_during_flash|Commands you want to be executed during flash|<parameter name="switchbox_commands_during_flash" value="" />|
    #  |:optional_parameters_after_flashing|Optional flash parameters|<parameter name="optional_parameters_after_flashing" value="" />|
    #  |:flash_images|Images to flash|<parameter name="flash_images" value="" />|
    #  |:sleep_time_after_flash_command|Wait time for the flash process to finish|<parameter name="sleep_time_after_flash_command" value="70" />|
    #  |:command_after_flash|Flash command after flash|<parameter name="command_after_flash" value="" />|
    #  |:switchbox_commands_after_failed_flash|Commands for switchbox after failed flash|<parameter name="switchbox_commands_after_failed_flash" value="" />|
    #  |:commands_after_failed_flash|Commands after failed flash|<parameter name="commands_after_failed_flash" value="" />|
    #  |:flash_command_success_string|If no error then no string is displayed|<parameter name="flash_command_success_string" value="" />|
    #  |:switchbox_commands_after_flash|Commands you want to be executed after flash|<parameter name="switchbox_commands_after_flash" value="" />|
    def flash_images(flash_files = nil)
      file, line = caller.first.split(":")

      begin
        if parameter(:flaxi_flash_attempts)
          $stderr.puts "%s:%s warning: parameter :flaxi_flash_attempts deprecated use :flash_attempts instead" % [ file, line]
          parameter[:flash_attempts]=parameter(:flaxi_flash_attempts)
        end
      rescue
      end

      begin
        if parameter(:flaxi_commands_before_flash)
          $stderr.puts "%s:%s warning: parameter :flaxi_commands_before_flash deprecated use :commands_before_flash instead" % [ file, line]
          parameter[:commands_before_flash]=parameter(:flaxi_commands_before_flash)
        end
      rescue
      end

      begin
        if parameter(:flaxi_flash_command)
          $stderr.puts "%s:%s warning: parameter :flaxi_flash_command deprecated use :flash_command instead" % [ file, line]
          parameter[:flash_command]=parameter(:flaxi_flash_command)
        end
      rescue
      end

      begin
        if parameter(:flaxi_optional_parameters_after_flashing)
          $stderr.puts "%s:%s warning: parameter :flaxi_optional_parameters_after_flashing deprecated use :optional_parameters_after_flashing instead" % [ file, line]
          parameter[:optional_parameters_after_flashing]=parameter(:flaxi_optional_parameters_after_flashing)
        end
      rescue
      end

      begin
        if parameter(:flaxi_flash_images)
          $stderr.puts "%s:%s warning: parameter :flaxi_flash_images deprecated use :flash_images instead" % [ file, line]
          parameter[:flash_images]=parameter(:flaxi_flash_images)
        end
      rescue
      end

      begin
        if parameter(:flaxi_sleep_time_after_flash_command)
          $stderr.puts "%s:%s warning: parameter :flaxi_sleep_time_after_flash_command deprecated use :sleep_time_after_flash_command instead" % [ file, line]
          parameter[:sleep_time_after_flash_command]=parameter(:flaxi_sleep_time_after_flash_command)
        end
      rescue
      end

      begin
        if parameter(:flaxi_command_after_flash)
          $stderr.puts "%s:%s warning: parameter :flaxi_command_after_flash deprecated use :command_after_flash instead" % [ file, line]
          parameter[:command_after_flash]=parameter(:flaxi_command_after_flash)
        end
      rescue
      end

      begin
        if parameter(:flaxi_commands_after_failed_flash)
          $stderr.puts "%s:%s warning: parameter :flaxi_commands_after_failed_flash deprecated use :commands_after_failed_flash instead" % [ file, line]
          parameter[:commands_after_failed_flash]=parameter(:flaxi_commands_after_failed_flash)
        end
      rescue
      end

      begin
        if parameter(:flaxi_flash_command_success_string)
          $stderr.puts "%s:%s warning: parameter :flaxi_flash_command_success_string deprecated use :flash_command_success_string instead" % [ file, line]
          parameter[:flash_command_success_string]=parameter(:flaxi_flash_command_success_string)
        end
      rescue
      end
        
      if flash_files==nil
        flash_files=parameter(:flash_images)
        Kernel::raise MobyBase::BehaviourError.new("flash_images", "flash_images not defined for sut in tdriver_parameters.xml") if flash_files == nil
      end

      str_flash_command=parameter(:flash_command)
      Kernel::raise MobyBase::BehaviourError.new("flash_images", "flash_command not defined for sut in tdriver_parameters.xml") if str_flash_command == nil

      str_optional_parameters=parameter(:optional_parameters_after_flashing,'')
      Kernel::raise MobyBase::BehaviourError.new("flash_images", "optional_parameters_after_flashing not defined for sut in tdriver_parameters.xml") if str_optional_parameters == nil

      #build flash command
      flash_command="#{str_flash_command} #{flash_files} #{str_optional_parameters}"

      #start flashing
      result = start_flashing( flash_command )
      
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
      execute_command_sequence(:commands_after_failed_flash)

    end

    def start_flashing(flash_command)

      flash_attempts=parameter(:flash_attempts)
      Kernel::raise MobyBase::BehaviourError.new("start_flashing", "flash_attempts not defined for sut in tdriver_parameters.xml") if flash_attempts == nil

      current_flash_attempt=0
      flash_result='false'


      while current_flash_attempt < flash_attempts.to_i
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
          current_flash_attempt=flash_attempts.to_i
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
      execute_command_sequence(:commands_before_flash)

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
      execute_command_sequence(:command_after_flash)

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end

end

