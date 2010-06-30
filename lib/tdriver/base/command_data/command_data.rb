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

	# Class to represent Controller interface

	class CommandData

		def initialize
		end

		def set_application_uid( id )
			@_application_id = id
		end

		def get_application_id
			@_application_id = "" unless @_application_id
			@_application_id
		end

		def set_sut( sut )
			@_sut = sut
		end

		def get_sut( sut )
			@_sut
		end

	end

end # module
