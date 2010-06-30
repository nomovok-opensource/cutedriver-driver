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


file, line = caller.first.split(":")
$stdout.puts "%s:%s warning: require 'matti' deprecated, use require 'tdriver' instead also 'MATTI' is deprecated, use 'TDriver' instead " % [ file, line]

# load matti resources and framework
require File.expand_path( File.join( File.dirname( __FILE__ ), 'tdriver/env' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'tdriver/version' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'tdriver/matti' ) )
