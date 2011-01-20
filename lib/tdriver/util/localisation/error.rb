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

	# This error should be raised when referred language is not found
	class LanguageNotFoundError < CustomError; end;

	# This error should be raised when referred table is not found
	class TableNotFoundError < CustomError; end;

	# This error should be raised when referred logical name is not found for specified language
	class LogicalNameNotFoundError < CustomError; end;

end
