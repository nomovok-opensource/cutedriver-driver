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

	class ParameterUserAPI

		include Singleton

		def []=( key, value )

			MobyUtil::Parameter[ key ] = value

		end

		def []( *args )

			MobyUtil::Parameter[ *args ]
		end

		def fetch( *args, &block )

			MobyUtil::Parameter.fetch( *args, &block )

		end

		def files

			MobyUtil::Parameter.files

		end

		def clear

			MobyUtil::Parameter.instance.clear
		end

		def load_xml( filename )

			MobyUtil::Parameter.instance.load_parameters_xml( filename )

		end

		def reset( *keys )

			MobyUtil::Parameter.instance.reset_parameters

		end

		def inspect

			MobyUtil::Parameter.inspect

		end

		def to_s

			MobyUtil::Parameter.to_s

		end

		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ParameterUserAPI

end # MobyUtil
