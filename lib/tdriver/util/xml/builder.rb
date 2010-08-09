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

	module XML    

		class Builder

			include Abstraction

			def initialize( &block )

				if block_given?

					$stderr.puts "%s:%s warning: deprecated method %s#new, use %s instead" % [ caller.first.split( ":" )[ 0 .. 1 ], self.class, "MobyUtil::XML#build" ].flatten

					# get current parser
					@parser = MobyUtil::XML.current_parser

					# extend builder behaviour of current parser
					self.extend( ( @parser )::Builder )

					# create builder object
					build( &block )

				end

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

		end # Builder

	end # XML

end # MobyUtil
