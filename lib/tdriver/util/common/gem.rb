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

  class GemHelper

    def self.create_build_files

      # Create build files. These are required, as RubyGems expects that external dependencies 
      # are built during the gem installation process and will not complete the installation 
      # if these files are missing.

      begin

        # remove following line when native extensions are supported by tdriver
        #raise LoadError

        # skip native extension build if running in java environment
        raise LoadError if MobyUtil::EnvironmentHelper.java?

        # skip also if windows env. until proper solution found how to compile in windows env.
        raise LoadError if MobyUtil::EnvironmentHelper.windows? 

        # makefile creation module
        require 'mkmf'
        
        # name of ruby native extension
        extension_name = 'tdriver/native_extensions'

        # destination
        dir_config( extension_name )

        # create makefile for implementation 
        create_makefile( extension_name )

      rescue Exception

        # create dummy makefile if building native extension fails or is not supported
        File.open( 'Makefile', 'w' ) { | f | f.write "all:\n\ninstall:\n\n" }

        if MobyUtil::EnvironmentHelper.windows? 

          File.open( 'nmake.bat', 'w') { |f| f.write "SET ERRORLEVEL=0" }
          File.open( 'make.bat', 'w') { |f| f.write "SET ERRORLEVEL=0" }
          File.open( 'extconf.dll', 'w' ) {}

        else

          File.open( 'make', 'w' ){ | f | f.write '#!/bin/sh'; f.chmod f.stat.mode | 0111; }
          File.open( 'extconf.so', 'w' ) {}

        end

      end

    end

    def self.grant_file_access_rights( folder, user_name = nil, user_group = nil )

      if MobyUtil::EnvironmentHelper.posix?

        # change folder ownership to user and add writing access to each file
        user_name = MobyUtil::EnvironmentHelper.user_name if user_name.nil?
        user_group = MobyUtil::EnvironmentHelper.user_group( user_name ) if user_group.nil?

        MobyUtil::EnvironmentHelper.change_file_ownership!( folder, user_name, user_group, true )

        `chmod -R u+w #{ folder }`

      end

    end

    # TODO: document
    def self.install( *parameters, &block )

      raise ArgumentError.new( "Target folder must be specified as first argument" ) if parameters.empty?

      yield( *parameters )

      MobyUtil::GemHelper.create_build_files

      MobyUtil::GemHelper.grant_file_access_rights( parameters.first )

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # GemHelper

end # MobyUtil
