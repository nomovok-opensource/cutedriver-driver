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

require 'singleton'

require 'rubygems'

[ 
  # hooking module - should be loaded first due to above modules uses its functions
  'hooking/hooking.rb', 

  # common utility modules
  'common/loader.rb',

  # logger module
  'logger/logger.rb',

  # parameter modules
  'xml/loader.rb',

  # statistics module
  'statistics/statistics.rb',

  # filter modules
  'filters/loader.rb', 

  # plugin service modules
  'plugin/loader.rb', 

  # parameter modules
  'parameter/loader.rb', 

  # database access module
  'database/loader.rb', 

  # localisation module
  'localisation/loader.rb', 

  # user data module
  'user_data/loader.rb', 

  # operator data module
  'operator_data/loader.rb', 

  # recorder and scripter modules
  'recorder/loader.rb', 

  # agent service command modules
  'agent/loader.rb', 

  # fixture service modules
  'fixture/loader.rb', 

  # video capture/util modules
  'video/loader.rb',

  # keymap utility modules
  'keymap/keymap.rb'

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}
