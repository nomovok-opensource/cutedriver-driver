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

# video utils module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'video_utils.rb' ) )

# camera implementation
require File.expand_path( File.join( File.dirname( __FILE__ ), 'camera.rb' ) )

# camera windows implementation
require File.expand_path( File.join( File.dirname( __FILE__ ), 'camera_windows.rb' ) )

# camera linux implementation
require File.expand_path( File.join( File.dirname( __FILE__ ), 'camera_linux.rb' ) )

