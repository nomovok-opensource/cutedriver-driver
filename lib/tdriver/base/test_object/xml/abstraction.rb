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

module TDriver

  module Abstraction
  
    module TestObjectAdapter

      # TODO: document me
      def identify_test_object_adapter_from_data( source )
   
        # verify check that source data is given in correct format
        source.check_type [ String, MobyUtil::XML::Element ], 'wrong argument type $1 for XML data source (expected $2)'

        # parse if given source is type of string    
        source = MobyUtil::XML.parse_string( source ).root if source.kind_of?( String )

        # determine xml format        
        if source.kind_of?( MobyUtil::XML::Element )

          # detect optimized xml format
          if source.xpath('.//obj[1]').count > 0

            TDriver::OptimizedXML::TestObjectAdapter
          
          # or deprecated xml format
          elsif source.xpath('.//object[1]').count > 0

            TDriver::TestObjectAdapter
          
          # or raise exception if format was not detected
          else
          
            raise RuntimeError, 'Unsupported XML data format'

          end
                  
        end # if
      
      end # identify_test_object_adapter

    end # TestObjectAdapter
  
  end # Abstraction

end # TDriver
