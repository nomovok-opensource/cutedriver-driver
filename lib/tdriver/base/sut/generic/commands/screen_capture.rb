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
		# attributes:: (optional) Hash of image related attributes
		# == returns
		# Instance of ScreenCapture
		def initialize( attributes = {} )

      # verify that attributes argument is type of Hash
      attributes.check_type( Hash, "Wrong argument type $1 for screen capture command attributes (expected $2)" )

      # set default values unless already defined in attributes hash
      attributes.default_values( :type => :Screen, :mime_type => :PNG, :color_depth => :Color4K, :redraw => false )

      # verify that value of :type is type of Symbol
      ( @command = attributes[ :type ] ).check_type( Symbol, "Wrong argument type $1 for screen capture command type (expected $2)" )

      # verify that value of :mime_type is type of Symbol
      ( @image_mime_type = attributes[ :mime_type ] ).check_type( Symbol, "Wrong argument type $1 for screen capture command mime type (expected $2)" )

      # verify that value of :color_depth is type of Symbol
      ( @color_depth = attributes[ :color_depth ] ).check_type( Symbol, "Wrong argument type $1 for screen capture command image color depth type (expected $2)" )

      # verify that value of :redraw is type of Symbol
      ( @redraw = attributes[ :redraw ] ).check_type( [ TrueClass, FalseClass ], "Wrong argument type $1 for screen capture command redraw flag (expected $2)" )
    
		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ScreenCapture

end # MobyCommand
