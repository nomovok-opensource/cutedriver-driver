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

  # load parser implementations
  'parsers/loader.rb',

  # xml related errors
  'error.rb',

  # abstraction module for document, element and nodeset
  'abstraction.rb',

  # comment object
  'comment.rb',

  # document object
  'document.rb',

  # element object
  'element.rb',

  # text object
  'text.rb',

  # attribute object
  'attribute.rb',

  # nil element object
  'nil_node.rb',

  # nodeset object
  'nodeset.rb',

  # xml Builder module
  'builder.rb',

  # xml api
  'xml.rb'

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}
