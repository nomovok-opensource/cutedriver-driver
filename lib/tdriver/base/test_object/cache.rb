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

# TODO: document me  
module TDriver

  # TODO: document me  
  class TestObjectCache

    # TODO: document me  
    @@cache = {}

    # TODO: document me  
    def initialize
    
      # raise exception if instance of this class is initialized
      raise RuntimeError.new("TDriver::TestObjectCache cannot be initialized due to it is a static class")
    
    end # initialize

    # TODO: document me  
    def self.object_keys( parent )
    
      ( @@cache[ parent.hash ] || {} ).keys
    
    end # self.object_keys

    # TODO: document me  
    def self.object_values( parent )
    
      ( @@cache[ parent.hash ] || {} ).values
    
    end # self.object_values
    
    # TODO: document me  
    def self.object_exists?( parent, test_object )
    
      ( @@cache[ parent.hash ] || {} ).has_key?( test_object.hash ) 
    
    end # self.object_exists?

    # TODO: document me  
    def self.add_object( parent, test_object )
      
      # add test object to parent hash
      ( @@cache[ parent.hash ] ||= {} ).merge!( test_object.hash => test_object )
      
    end # self.add_object
  
    # TODO: document me  
    def self.remove_object( parent, test_object )

      # calculate hash only once, used multiple times below
      parent_hash = parent.hash
      
      # calculate hash only once, used multiple times below
      test_object_hash = test_object.hash

      # verify that key is found from hash
      if ( @@cache[ parent_hash ] || {} ).has_key?( test_object_hash )
      
        # remove test object from parent object hash
        @@cache[ parent_hash ].delete( test_object_hash )
      
      else
      
        # raise exception if key not found from hash
        raise RuntimeError.new("Test object not found from cache")
      
      end
    
    end # self.remove_object
      
  end # TestObjectCache

end # TDriver
