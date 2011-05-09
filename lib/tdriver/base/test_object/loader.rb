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

# load test object abstract class
require File.expand_path( File.join( File.dirname( __FILE__ ), 'abstract' ) )

# load test object identificator
#require File.expand_path( File.join( File.dirname( __FILE__ ), 'identificator' ) )

# load test object factory
require File.expand_path( File.join( File.dirname( __FILE__ ), 'factory' ) )

# load test object cache
require File.expand_path( File.join( File.dirname( __FILE__ ), 'cache' ) )

# load test object adapter
require File.expand_path( File.join( File.dirname( __FILE__ ), 'adapter' ) )

# load test object adapter
require File.expand_path( File.join( File.dirname( __FILE__ ), 'xml/adapter' ) )

# load verify ui module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'verification' ) )

# load test object behaviours
MobyUtil::FileHelper.load_modules( File.expand_path( File.join( File.dirname( __FILE__ ), 'behaviours' ) ) )

# load report api for continous verification reporting purposes
require File.expand_path( File.join( File.dirname( __FILE__ ), '../../report/report_api' ) ) if MobyUtil::Parameter[ :report_attach_continuous_verification_to_reporter, nil ]=='true'

