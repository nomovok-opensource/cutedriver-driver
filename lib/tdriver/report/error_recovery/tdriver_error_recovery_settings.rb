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





class TDriverErrorRecoverySettings
  def initialize

    @error_recovery_enabled=nil

    @ping_connection=nil

    @ping_interval=nil

    @reconnect_device=nil

    @reconnect_attempts=nil

    @monitored_suts=[]

    @ats4_error_recovery_enabled=false

    @wait_time_for_ats4_error_recovery=60

    read_settings
  end
  # Read error recovery settings
  # === params
  # === returns
  # === raises
  def read_settings()
    @error_recovery_enabled=MobyUtil::Parameter[ :error_recovery_enabled ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "error recovery enabled parameter not defined in tdriver_parameters.xml") if @error_recovery_enabled == nil

    @ats4_error_recovery_enabled=MobyUtil::Parameter[ :ats4_error_recovery_enabled ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "ats4 error recovery enabled parameter not defined in tdriver_parameters.xml") if @ats4_error_recovery_enabled == nil

    @wait_time_for_ats4_error_recovery=MobyUtil::Parameter[ :wait_time_for_ats4_error_recovery ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "ats4 error recovery wait time parameter not defined in tdriver_parameters.xml") if @wait_time_for_ats4_error_recovery == nil

    @ping_connection=MobyUtil::Parameter[ :ping_connection ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "ping connection parameter not defined in tdriver_parameters.xml") if @ping_connection == nil

    @reconnect_device=MobyUtil::Parameter[ :reconnect_device ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "reconnect device patameter not defined in tdriver_parameters.xml") if @reconnect_device == nil

    @reconnect_attempts=MobyUtil::Parameter[ :reconnect_attempts ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "reconnect attempts patameter not defined in tdriver_parameters.xml") if @reconnect_attempts == nil

    str_parameter=MobyUtil::Parameter[ :error_recovery_monitored_sut_ids ]
    Kernel::raise MobyBase::BehaviourError.new("error recovery", "error_recovery_monitored_sut_ids patameter not defined in tdriver_parameters.xml") if str_parameter == nil
    @monitored_suts=str_parameter.split('|')


  end
  def get_ats4_error_recovery_enabled
    MobyUtil::Parameter[ :ats4_error_recovery_enabled ]
  end
  def get_wait_time_for_ats4_error_recovery
    MobyUtil::Parameter[ :wait_time_for_ats4_error_recovery ]
  end
  def get_error_recovery_enabled
    MobyUtil::Parameter[ :error_recovery_enabled ]
  end
  def get_ping_connection
    MobyUtil::Parameter[ :ping_connection ]
  end
  def get_reconnect_device
    MobyUtil::Parameter[ :reconnect_device ]
  end
  def get_reconnect_attempts
    MobyUtil::Parameter[ :reconnect_attempts ]
  end
  def get_monitored_sut
    str_parameter=MobyUtil::Parameter[ :error_recovery_monitored_sut_ids ]
    @monitored_suts=str_parameter.split('|')
    @monitored_suts
  end

end
