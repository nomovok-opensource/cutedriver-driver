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

module MobyUtil

  # Base class and interface for camera recorders in TDriver
  class TDriverCam

    # Automatically select the right kind of camera implementation for the detected platform.
    def self.new_cam( *args )

      if EnvironmentHelper.windows?

        MobyUtil::TDriverWinCam.new( *args )

      elsif EnvironmentHelper.linux?

        MobyUtil::TDriverLinuxCam.new( *args )

      else

        raise RuntimeError.new("Unidentified platform type, unable to select platform specific camera. Supported platform types: Linux, Windows.")

      end

    end

    def initialize

      raise RuntimeError.new("TDriverCam abstract class")

    end

    def start_recording

      raise RuntimeError.new("TDriverCam abstract class")

    end

    def stop_recording

      raise RuntimeError.new("TDriverCam abstract class")

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # TDriverCam

end # MobyUtil
