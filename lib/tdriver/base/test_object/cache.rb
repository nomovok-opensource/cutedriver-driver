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
    def initialize()

      @objects = {}

    end
    
    # TODO: document me  
    def each_object( &block )
    
      @objects.each_value{ | object | yield( object ) }
    
    end
    
    # TODO: document me  
    def objects
    
      @objects
    
    end
    
    # TODO: document me  
    def has_object?( test_object )
    
      @objects.has_key?( test_object.hash )
    
    end
    
    # TODO: document me  
    def object_keys
    
      @objects.keys
    
    end
    
    # TODO: document me  
    def object_values
    
      @objects.values
        
    end
    
    # TODO: document me  
    def []( value )
    
      @objects.fetch( value.hash ){ raise ArgumentError, "Test object (#{ value.hash }) not found from cache" }
    
    end
    
    # TODO: document me  
    def add_object( test_object )

      test_object_hash = test_object.hash

      if @objects.has_key?( test_object_hash )
        warn( "Warning: Test object (#{ test_object_hash }) already exists in cache" )
      end
    
      @objects[ test_object_hash ] = test_object
    
      test_object
    
    end

    # TODO: document me  
    def remove_object( test_object )
    
      test_object_hash = test_object.hash
    
      raise ArgumentError, "Test object (#{ value.hash }) not found from cache" unless @objects.has_key?( test_object_hash )
    
      @objects.delete( test_object_hash )
    
      self
    
    end

    # TODO: document me  
    def remove_objects
    
      @objects.clear
    
    end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # TestObjectCache

end # TDriver
