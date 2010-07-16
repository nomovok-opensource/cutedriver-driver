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

# Hooking module - should be loaded first due to above modules uses its functions
require File.expand_path( File.join( File.dirname( __FILE__ ), 'hooking.rb' ) )

# generic/common utility modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'common/loader.rb' ) )

# Logger module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'logger.rb' ) )

# Parameter modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'xml/loader.rb' ) )

# Statistics module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'stats.rb' ) )

# Dynamic attribute filter module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'dynamic_attribute_filter' ) )

# Plugin service & abstract class
require File.expand_path( File.join( File.dirname( __FILE__ ), 'plugin/loader.rb' ) )

# Parameter modules
require File.expand_path( File.join( File.dirname( __FILE__ ), 'parameter/loader.rb' ) )

# DBAccess module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'dbaccess/loader.rb' ) )

# Localisation module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'localisation/loader.rb' ) )

# User Data module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'user_data/loader.rb' ) )

# Operator Data module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'operator_data/loader.rb' ) )

# Recorder module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'recorder.rb' ) )

