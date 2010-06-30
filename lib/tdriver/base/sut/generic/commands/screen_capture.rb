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


module MobyCommand

	class ScreenCapture < MobyCommand::CommandData

		attr_accessor(
			:command, 
			:image_mime_type, 
			:color_depth, 
			:redraw
		)

		# Constructor to ScreenCapture
		# == params
		# hash:: (optional) Hash of image related attributes
		# == returns
		# Instance of ScreenCapture
		def initialize( hash = {} )

			# Default values
			@command = hash[ :type ] ||= :Screen
			@image_mime_type = hash[ :mime_type ] ||= :PNG
			@color_depth = hash[ :color_depth ] ||= :Color4K
			@redraw = hash[ :redraw ] ||= false

			Kernel::raise ArgumentError.new("Wrong argument type %s for command type (expected Symbol)" % hash[ :type ].class ) unless hash[ :type ].kind_of? Symbol

			Kernel::raise ArgumentError.new("Wrong argument type %s for image MIME type (expected Symbol)" % hash[ :mime_type ].class ) unless hash[ :mime_type ].kind_of? Symbol

			Kernel::raise ArgumentError.new("Wrong argument type %s for image color depth type (expected Symbol)" % hash[ :color_depth ].class ) unless hash[ :color_depth ].kind_of? Symbol

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ScreenCapture

end # MobyCommand
