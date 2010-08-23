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

  class EnvironmentHelper

    LINUX = 0
    WINDOWS = 1
    OSX = 2
    OTHER = 3

    def self.linux?

      platform == LINUX

    end

    def self.windows?

      platform == WINDOWS

    end

    def self.osx?

      platform == OSX

    end

    def self.unknown?

      platform == OTHER

    end

    # Function to retrieve platform type
    # == returns
    # Integer:: LINUX 
    def self.platform

      case Config::CONFIG[ 'host_os' ]

        when /mswin|mingw/i

          WINDOWS

        when /linux/i

          LINUX

        when /darwin/

          OSX

      else

        OTHER

      end

    end

    # Function to retrieve platform type
    # == returns
    # String:: 
    def self.ruby_platform

      Config::CONFIG[ 'target_os' ]

    end

    def self.change_file_ownership!( target, user_name, user_group, recursively = true )

      `chown -h #{ recursively ? '-R' : '' } #{ user_name }:#{ user_group } #{ target }` unless MobyUtil::EnvironmentHelper.ruby_platform =~ /mswin/

    end

    # linux
    def self.user_group( name = nil )

            `id -g -n #{ name }`.chomp unless MobyUtil::EnvironmentHelper.ruby_platform =~ /mswin/

    end

    # linux
    def self.user_name

      result = ENV[ 'LOGNAME' ]
      result = ENV[ 'SUDO_USER' ] if result == "root" || result == ""
      result = ENV[ 'USER' ] if result == "root" || result == ""

      result

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # EnvironmentHelper

end # MobyUtil
