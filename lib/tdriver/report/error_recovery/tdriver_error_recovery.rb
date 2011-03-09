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


module TDriverErrorRecovery

  # Initializes error recovery settings
  # === params
  # === returns
  # === raises
  def initialize_error_recovery
    @recovery_settings=TDriverErrorRecoverySettings.new
    if @recovery_settings.get_ats4_error_recovery_enabled=='true'
      eval('module TDriver_Error_Recovery_ATS4
        require \'dl/import\'
        extend DL::Importable
        dlload "callbackif"
        extern "void restartDatagateway(const char*)"
        extern "int error()"
        extern "int getBootTimeout(const char*)"
      end')
    end

  end

  # Starts the error recovery for SUTs
  # === params
  # === returns
  # === raises
  def start_error_recovery()
    resetted=false
    if @recovery_settings.get_error_recovery_enabled=='true'
      MobyUtil::Logger.instance.log "behaviour" , "PASS;Starting error recovery"
      if @recovery_settings.get_reconnect_device=='true'
        if @recovery_settings.get_ping_connection=='true'
          resetted=ping_devices_and_reconnect()
        else
          reconnect_devices()
          resetted=true
        end
      end
      MobyUtil::Logger.instance.log "behaviour" , "PASS;Error recovery complete"
    end
    resetted
  end

  # attempts a reconnect for the current SUT
  # === params
  # current_sut
  # === returns
  # === raises
  def attempt_reconnect(current_sut)
    MobyUtil::Logger.instance.log "behaviour" , "WARNING;Connection lost attempting to reconnect"
    attempt_reconnects=@recovery_settings.get_reconnect_attempts
    current_reconnect_attempt=0
    b_error_recovery_succesful=false
    while current_reconnect_attempt.to_i<attempt_reconnects.to_i
      if @recovery_settings.get_ats4_error_recovery_enabled=='true'
        MobyUtil::Logger.instance.log "behaviour" , "WARNING;Restarting ATS4 DataGateway"
        TDriver_Error_Recovery_ATS4.restartDatagateway(current_sut.id.to_s);
        ats_timeout=TDriver_Error_Recovery_ATS4.getBootTimeout(current_sut.id.to_s);
        sleep ats_timeout.to_i
        MobyUtil::Logger.instance.log "behaviour" , "WARNING;ATS4 DataGateway restarted"
      else
        MobyUtil::Logger.instance.log "behaviour" , "WARNING;Resetting sut: #{current_sut.id.to_s}"
        current_sut.reset
        MobyUtil::Logger.instance.log "behaviour" , "WARNING;Sut resetted"
      end
      if ping_device(current_sut)==true
        b_error_recovery_succesful=true
        MobyUtil::Logger.instance.log "behaviour" , "PASS;Device reconnected"
        current_reconnect_attempt=attempt_reconnects.to_i
      else
        current_reconnect_attempt+=1
      end
    end
    Kernel::raise BehaviourError.new("Error Recovery", "Error recovery failed after #{attempt_reconnects} recovery attempts") if b_error_recovery_succesful==false
  end

  # Reconnects the devices without ping
  # === params
  # === returns
  # === raises
  def reconnect_devices()

      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        suts=@recovery_settings.get_monitored_sut
        suts.each do |monitored_sut|
          if sut_id.to_s==monitored_sut.to_s
            attempt_reconnect(sut_attributes[:sut])
          end
        end
      end

  end

  # Ping the current SUT by querying xml state
  # === params
  # current sut
  # === returns
  # true for succesful ping
  # false for failed ping
  # === raises
  def ping_device(current_sut)
    begin
      xml_state=current_sut.get_ui_dump()
      if xml_state.to_s.include?("tasMessage")==false
        MobyUtil::Logger.instance.log "behaviour" , "WARNING;Device ping failed"
        false
      else
        MobyUtil::Logger.instance.log "behaviour" , "PASS;Device ping succesful"
        true
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      MobyUtil::Logger.instance.log "behaviour" , "WARNING;Device ping failed"
      false
    end
  end

  # Ping the devices and reconnect if ping fails
  # === params
  # === returns
  # === raises
  def ping_devices_and_reconnect()
    resetted=false
    MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        suts=@recovery_settings.get_monitored_sut
        suts.each do |monitored_sut|
          if sut_id.to_s==monitored_sut.to_s
            if ping_device(sut_attributes[:sut])==false
              resetted=true
              attempt_reconnect(sut_attributes[:sut])
            end
          end
        end
    end
    resetted
  end

end
