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

[ 

  # load test object abstract class
  'abstract',

  # load test object factory
  'factory',

  # load test object cache
  'cache',

  # load test object adapter abstraction
  'xml/abstraction',

  # load test object adapter
  'xml/adapter',

  # load test object adapter
  'adapter',

  # load verify ui module
  'verification'

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}

# load test object behaviours
MobyUtil::FileHelper.load_modules( File.expand_path( File.join( File.dirname( __FILE__ ), 'behaviours' ) ) )

