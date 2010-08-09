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

require File.expand_path( File.join( File.dirname( __FILE__ ), 'tdriver' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'loader' ) )

class MATTI

	def self.method_missing( method_id, *args )

		file, line = caller.first.split(":")

		$stderr.puts "%s:%s warning: deprecated class %s, use %s#%s instead" % [ file, line, self.name, "TDriver", method_id.to_s ]

		TDriver.respond_to?( method_id ) ? TDriver.method( method_id ).call( *args ) : super

	end

end
