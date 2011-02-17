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
# Generic configuration file for sut setup.
# Can be used to provide ruby code for sut configurations.
module MobyBehaviour
  module SUT
	  # Setup method for sut that will be executed when @sut.setup is called  
	  # Methods for sut can be called with self
	  # Example:
	  # self.run(:name => 'testapp')
	  def setup
		puts "Hello world"		
	  end
  end
end
  
