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

    # This error should be raised when no database type is defined
	class DbTypeNotDefinedError < CustomError; end;

	# This error should be raised when not supported db type is defined
	class DbTypeNotSupportedError < CustomError; end;
	
	# This error should be raised when there is connectivity problem with sql database
	class SqlConnectError < CustomError; end;
	
	# This error should be raised when there is problem with sql query
	class SqlError < CustomError; end;
	
end
