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

# load globally used external modules
require 'singleton'

#require 'set'

begin

  # load native extensions if available
  require File.expand_path( File.join( File.dirname( __FILE__ ), 'native_extensions' ) )

rescue LoadError

  # do nothing

end

# utility modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'util/loader.rb' ) )

# base modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'base/loader.rb' ) )

# reporting modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report/report.rb' ) )

# verify module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'verify/verify.rb' ) )

