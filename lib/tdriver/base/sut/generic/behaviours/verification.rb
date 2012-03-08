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
    # NOTE: This won't work with the visibleOnScreen attribute unless you disable the sut parameter use_find_object.
    #
    # == arguments
    # *attributes
    #  Hash
    #   description: Hash containing attributes that the object must have
    #   example: {}
    #
    # == returns
    # TrueClass
    #  description: if the object exists on the sut display
    #  example: true
    #
    # FalseClass
    #  description: if the object exists on the sut display
    #  example: false
    #
    # == exceptions
    # TypeError
    #  description: Wrong argument type <class> for test object type (expected String)
    #
    # ArgumentError
    #  description: The test object type argument must not be empty
    #
    # ArgumentError
    #  description: Test object attributes hash argument must not be empty
    #
    # TypeError
    #  description: Wrong argument type <class> for test object attributes (expected Hash)
    def test_object_exists?( *attributes )

      begin

        # store original number of arguments
        arguments_count = attributes.count

        # verify that correct number of arguments were given
        if ( 1..2 ).include?( arguments_count )

          # retrieve and remove first argument from array
          first = attributes.shift
                
          if first.kind_of?( Hash )

            # wrong number of arguments were given
            raise ArgumentError if attributes.count > 0
         
            # store first argument as attributes hash 
            attributes = first
          
            # verify that attributes hash is not empty
            attributes.not_empty( 'Test object attributes hash argument must not be empty' )
          
          elsif first.kind_of?( String )

            # print deprecated method usage warning  
            warn "deprecated method usage; use object#test_object_exists?( Hash ) instead of object#test_object_exists?( String, [ Hash ] )"

            # verify that type is not empty string
            first.not_empty( 'The test object type argument must not be empty' )

            # retrieve attributes from argument; optional argument when type is kind of String
            attributes = attributes.shift || {}

            # verify that attributes argument type is correct (Hash)
            attributes.check_type Hash, 'wrong argument type $1 for test object attributes (expected $2)'
            
            # store test object type to attributes hash
            attributes[ :type ] = first
            
          else

            # verify that first argument type is correct (Hash or String)
            first.check_type Hash, 'wrong argument type $1 for test object type (expected $2)'
            
          end
          
        else

          # wrong number of arguments were given
          raise ArgumentError
          
        end
      
      rescue ArgumentError

        # raise argument error; pass with proper description
        raise ArgumentError, "wrong number of arguments (#{ arguments_count } for 1)"
        
      end

      # make clone of original attributes
      attributes_clone = attributes.clone

      # If empty or only special attributes then add :type => '*' to search all
      attributes_clone[ :type ] = '*' if attributes_clone.select{ | key, value | key.to_s !~ /^__/ ? true : false }.empty?

      # translate the symbol values into string using sut's localisation setting
      @sut.translate_values!( attributes_clone )

      # default result (raises exception)
      result = nil

      # disable logging temporarly      
      $logger.push_enabled( false )

      begin
              
        # raise exception if multiple objects found; call child method, disable logging and allow multiple objects  
        raise MobyBase::MultipleTestObjectsIdentifiedError if child( attributes_clone.merge( :__logging => false, :__multiple_objects => true ) ).count > 1

        # return true as return value
        result = true

        # result behaviour description
        description = "Test object with attributes #{ attributes.inspect } was found."

      rescue Exception
        
        case $!
        
          when MobyBase::MultipleTestObjectsIdentifiedError
          
            # return true as return value
            result = true
            
            # result behaviour description
            description = "Multiple objects with attributes #{ attributes.inspect } were found."
          
          when MobyBase::TestObjectNotFoundError

            # return false as return value
            result = false
            
            # result behaviour description
            description = "Test object with attributes #{ attributes.inspect } was not found."

          else
          
            # store exception to be raised
            result = $!
            
            # result behaviour description
            description = "Test object with attributes #{ attributes.inspect } was not found due to unexpected error (#{ $!.class }: #{ $!.message.inspect })"
        
        end

      ensure

        # determines that will result be logged to behaviour level 
        $logger.enabled = ( attributes[ :__logging ] == 'true' ? true : false )

        # behaviour logging
        $logger.behaviour "#{ ( result == true ? 'PASS' : 'FAIL' ) };#{ description };#{ ( sut? ? id.to_s : '' ) };test_object_exists?;" 
        
        # restore original logger state
        $logger.pop_enabled
        
        # raise exception if neccessery
        raise result if result.kind_of?( Exception )        

      end

      # return value
      result

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # module VerificationBehaviour

end # module MobyBase
