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

module MobyBehaviour
 
  # == description
  # Defines methods for verification of test object state. These methods can only be called from non-sut objects
  #
  # == behaviour
  # GenericVerification
  #
  # == requires
  # *
  #
  # == input_type
  # *
  #
  # == sut_type
  # *
  #
  # == sut_version
  # *
  #
  # == objects
  # *;application;sut
  #
  module Verification

    include MobyBehaviour::Behaviour

    # == description
    # Checks if a child test object matching the given criteria can be found, under this application object or test object.
    #
    # == arguments
    # type
    #  String
    #   description: String defining the type of the object
    #   example: "Button"
    #
    # attributes
    #  Hash
    #   description: Optional hash containing attributes that the object must have
    #   example: {}
    #
    # == returns
    # TrueClass
    #   description: if the object exists on the sut display
    #   example: true
    # FalseClass
    #   description: if the object exists on the sut display
    #   example: false
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type %s for test object type (expected String)
    #
    # ArgumentError
    #  description: The test object type argument must not be empty
    #
    # TypeError
    #  description: Wrong argument type %s for test object attributes (expected Hash)
    def test_object_exists?( type, attributes = {} )

      # verify type
      type.check_type( String, "Wrong argument type $1 for test object type (expected $2)" )

      # verify that type is not empty string
      type.not_empty( "The test object type argument must not be empty" )

      # verify attributes argument type
      attributes.check_type( Hash, "Wrong argument type $1 for test object attributes (expected $2)")

      attributes_with_type = attributes.clone

      attributes_with_type[ :type ] = type

      attributes_with_type.delete( :__logging )

      #translate the symbol values into string using sut's localisation setting
      @sut.translate_values!( attributes_with_type )

      original_logging = $logger.enabled
      
      desired_logging = ( attributes[ :__logging ] == nil || attributes[ :__logging ] == 'false') ? false : true
      
      $logger.enabled = false      

      begin

        self.child( attributes_with_type )

        $logger.enabled = desired_logging
        
        $logger.log "behaviour", "PASS;Test object of type #{type} with attributes #{attributes.inspect} was found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"

      rescue MobyBase::MultipleTestObjectsIdentifiedError

        $logger.enabled = desired_logging
        
        $logger.log "behaviour", "PASS;Multiple objects of type #{ type } with attributes #{attributes.inspect} were found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"

        return true

      rescue MobyBase::TestObjectNotFoundError

        $logger.enabled = desired_logging
        
        $logger.log "behaviour", "FAIL;Test object of type #{type} with attributes #{attributes.inspect} was not found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"

        return false

      rescue Exception

        $logger.enabled = desired_logging
        
        $logger.log "behaviour", "FAIL;Test object of type #{type} with attributes #{attributes.inspect} was not found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"

        Kernel::raise $!

      ensure

        $logger.enabled = original_logging

      end

      return true

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # module VerificationBehaviour

end # module MobyBase
