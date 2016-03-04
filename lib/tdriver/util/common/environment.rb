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

    unless defined?( UNKNOWN )    
      LINUX = :linux
      SOLARIS = :solaris
      WINDOWS = :windows
      OSX = :osx
      CYGWIN = :cygwin
      UNKNOWN = :unknown # keep this as last constant
    end
    
    def self.java?
    
      RUBY_PLATFORM == "java"

    end

    def self.posix?
    
      ( platform == LINUX || platform == OSX || platform == CYGWIN || platform == SOLARIS ) 
    
    end

    def self.cygwin?

      platform == CYGWIN
    
    end

    def self.solaris?

      platform == SOLARIS
    
    end

    def self.linux?

      platform == LINUX

    end

    def self.windows?

      platform == WINDOWS

    end

    def self.osx?

      platform == OSX

    end

    def self.unknown_os?

      platform == UNKNOWN

    end

    # Function to retrieve platform type
    # == returns
    # Integer:: LINUX 
    def self.platform

      case RbConfig::CONFIG[ 'host_os' ]

        when /mswin|mingw|windows/i

          WINDOWS

        when /cygwin/i
        
          CYGWIN

        when /linux/i

          LINUX

        when /sunos|solaris/i

          SOLARIS

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

      RbConfig::CONFIG[ 'target_os' ]

    end

    def self.change_file_ownership!( target, user_name, user_group, recursively = true )

      `chown -h #{ recursively ? '-R' : '' } #{ user_name }:#{ user_group } #{ target }` if MobyUtil::EnvironmentHelper.posix?

    end

    # linux
    def self.user_group( name = nil )

      `id -g -n #{ name }`.chomp if MobyUtil::EnvironmentHelper.posix?
      
    end

    # linux
    def self.user_name

      result = ENV[ 'LOGNAME' ]
      result = ENV[ 'SUDO_USER' ] if result == "root" || result == ""
      result = ENV[ 'USER' ] if result == "root" || result == ""

      result

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # EnvironmentHelper

end # MobyUtil
