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
  # TDriver synchronization functionality. These methods make it possible to wait until the SUT is in some user defined state
  #
  # == behaviour
  # GenericTestObjectSynchronization
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
  # *;sut
  #
	module TestObjectSynchronization

		include MobyBehaviour::Behaviour

    # == description
		# Wait until this test object has a child test object matching the given attributes or timeout exceeds. An exception will be raised if test object was not found in the specified timeout.
		#
		# == arguments
		# attributes
		#  Hash
		#   description: Hash defining the set of attributes that the child test object must possess.
		#   example: {:text=>'1'}
		#
		# timeout
		#  Fixnum
		#   description: Overriding the default synchronization timeout
		#   example: 30
		#
		# retry_interval
		#  Fixnum
		#   description: Time used before retrying to find test object 
		#   example: 1
		#
		# == returns
		# MobyBase::TestObject
		#  description: Returns receiver object of this method, not the found object 
		#  example: - 
		#
		# == exceptions
		# TypeError
		#  description: Wrong argument type %s for attributes (expected Hash)
		#
		# TypeError
		#  description: Wrong argument type %s for attribute :type (expected String)
		#
		# TypeError
		#  description: Wrong argument type %s for timeout (expected Integer, Fixnum or Float)
		#
		# ArgumentError
		#  description: Argument retry_interval was not a valid. Expected: Integer, Fixnum or Float
		#
		# MobyBase::SyncTimeoutError
		#  description: Synchronization timed out (%i) before the defined child object could be found
		#
		def wait_child( attributes = {}, timeout = 10, retry_interval = 0.5 )

      # verify that attributes is type of Hash
      attributes.check_type( Hash, "Wrong argument type $1 for attributes (expected $2)" )
  
      # verify that :type is type of String
      attributes[ :type ].check_type( String, "Wrong argument type $1 for attribute :type (expected $2)" )

      # verify that :type is not empty string
      attributes[ :type ].not_empty( "Attribute :type must not be empty" )

      # verify timeout type is numeric
      timeout.check_type( [ Integer, Fixnum, Float ], "Wrong argument type $1 for timeout (expected $2)" )

      # verify timeout type is numeric
      retry_interval.check_type( [ Integer, Fixnum, Float ], "Wrong argument type $1 for retry interval (expected $2)" )

			begin
			
        dynamic_attributes = attributes.strip_dynamic_attributes!

        # try to identify desired child test object
        @test_object_factory.identify_object(
          :object_attributes_hash => attributes,
          :identification_directives => dynamic_attributes.default_values(
            :__timeout => timeout,
            :__retry_interval => retry_interval,
            :__refresh_arguments => self.kind_of?( MobyBase::SUT ) ? attributes : { :id => self.get_application_id },
            :__parent_application => self.sut? == true ? nil : @parent_application 
          ),
          :parent => self        
        )
        
			rescue MobyBase::TestObjectNotFoundError

				# the child object was not found in the specified timeout
				raise MobyBase::SyncTimeoutError, "Synchronization timed out (#{ timeout }) before the defined child object could be found."
      
      rescue MobyBase::ApplicationNotAvailableError
        
        raise
      
      rescue # unexpected errors

				raise RuntimeError, "Synchronization failed due to #{ $!.message } (#{ $!.class })"

			end

			self

		end

		# enable hooking for performance measurement & debug logging
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # TDriverSyncronization

end # MobyBehaviour
