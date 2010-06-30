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
