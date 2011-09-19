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

  # behaviour abstraction class, factory and all other related modules etc
  'behaviour/loader.rb',

  # command_data abstraction class etc.
  'command_data/loader.rb',

  # command_data controller abstraction class etc.
  'controller/loader.rb',

  # sut abstract class, generic sut etc
  'sut/loader.rb',

  # error classes
  'errors.rb',

  # test object abstraction, factory, identificator behaviours and all other related modules
  'test_object/loader.rb',

  # state object
  'state_object.rb' 

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}
