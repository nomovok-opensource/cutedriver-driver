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

# nokogiri parser
require 'nokogiri'

# for utf-8/unicode support
require 'kconv'

[ 

  # abstraction for document, nodeset and element
  'abstraction.rb', 

  'node.rb',

  # nokogiri parser wrapper
  'comment.rb', 

  # nokogiri parser wrapper
  'document.rb', 

  # nokogiri parser wrapper
  'nodeset.rb', 

  # nokogiri parser wrapper
  'element.rb', 

  # nokogiri parser wrapper
  'text.rb', 

  # nokogiri parser wrapper
  'attribute.rb', 

  # nokogiri parser wrapper
  'builder.rb', 

].each{ | filename |

  require File.expand_path( File.join( File.dirname( __FILE__ ), filename ) )

}
