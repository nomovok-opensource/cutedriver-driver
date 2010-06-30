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
# Generic configuration file for sut data.
# Can be used to provide ruby code for sut configurations.
module SutParameters
  # Verify blocks define the verify_always blocks that are automatically added to given sut.  
  # Takes an array of VerifyBlock objects
  # VerifyBlock parameters:
  # - Proc block 
  # - Expected return value
  # - Error message
  # Configured verify_always blocks will not return the failed error block code in the error message.
  VERIFY_BLOCKS = [
                   # Example block
                   MobyUtil::VerifyBlock.new(
                                             Proc.new { |sut|
                                               # Verifies that some application is always running
                                               sut.application.name != "qttasserver"
                                             }, 
                                             true, "Top most application is qttas, no application is running")                                           
                  ]
end
  
