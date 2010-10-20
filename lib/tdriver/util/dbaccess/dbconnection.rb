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

	class DBConnection
		attr_accessor :db_type, :host, :database_name, :username, :password, :dbh
		
		# Initialize the singleton
		def initialize( db_type, host, database_name, username, password )
			@db_type = db_type
			@host = host
			@database_name = database_name
			@username = username
			@password = password
			@dbh = nil		
		end
		
	end # class

end # module

