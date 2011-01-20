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

require 'rbconfig'  # ??

# common modules - should be generic and runnable as standalone
[ 
  # Ruby object extensions
  'object.rb', 
  'numeric.rb', 
  'hash.rb', 
  'string.rb',
  
  'exceptions.rb', 
  'error.rb', # TODO: move custom exceptions to exceptions.rb
  
  'array.rb', 
  'crc16.rb', 
  'environment.rb', 
  'file.rb', 
  'gem.rb', 
  'kernel.rb', 
  'retryable.rb',
  'stackable.rb' 

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}
