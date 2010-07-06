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


# load parser implementation(s)
require File.expand_path( File.join( File.dirname( __FILE__ ), 'parsers/loader.rb' ) )

# xml related errors
require File.expand_path( File.join( File.dirname( __FILE__ ), 'error.rb' ) )


# abstraction module for document, element and nodeset
require File.expand_path( File.join( File.dirname( __FILE__ ), 'abstraction.rb' ) )

# document object
require File.expand_path( File.join( File.dirname( __FILE__ ), 'document.rb' ) )

# element object
require File.expand_path( File.join( File.dirname( __FILE__ ), 'element.rb' ) )

# element object
require File.expand_path( File.join( File.dirname( __FILE__ ), 'nil_element.rb' ) )

# nodeset object
require File.expand_path( File.join( File.dirname( __FILE__ ), 'nodeset.rb' ) )

# xml Builder module
require File.expand_path( File.join( File.dirname( __FILE__ ), 'builder.rb' ) )

# xml api
require File.expand_path( File.join( File.dirname( __FILE__ ), 'xml.rb' ) )

