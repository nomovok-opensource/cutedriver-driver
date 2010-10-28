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

		# Wait until this test object has a child test object of the specified type and matching the given attributes.
		# The child being waited for must be identifiable by the provided constraints. The call terminates 
		# only when exactly a single child matches the criteria.
		#
		# === params
		# type:: String defining the type of the child test object, eg. "list", "softkey"
		# attributes:: (optional) Hash defining the set of attributes that the child test object must possess.
		# timeout:: (optional) Integer overriding the default synchronization timeout.
		# === raises
		# ArgumentError:: One of the arguments was not of a valid format.
		# SyncTimeoutError:: The timeout has passed without synchronization success.
		def wait_child( attributes = {}, timeout_secs = 10, retry_interval = 0.5 )

			Kernel::raise ArgumentError.new( "Argument type was not a valid. Expected: String" ) unless attributes[ :type ].kind_of?( String ) && attributes[ :type ].length > 0

			Kernel::raise ArgumentError.new( "Argument attributes was not a valid. Expected: Hash" ) unless attributes.kind_of?( Hash )

			Kernel::raise ArgumentError.new( "Argument timeout_secs was not a valid. Expected: Integer, Fixnum or Float" ) unless [ Integer, Fixnum, Float ].include? timeout_secs.class

			Kernel::raise ArgumentError.new( "Argument retry_interval was not a valid. Expected: Integer, Fixnum or Float" ) unless [ Integer, Fixnum, Float ].include? retry_interval.class

			begin

				MobyUtil::Retryable.until( :timeout => timeout_secs, :interval => retry_interval ) {

					#self.refresh( attributes )

					self.refresh( self.kind_of?( MobyBase::SUT ) ? attributes : { :id => self.get_application_id } )

					MobyBase::TestObjectIdentificator.new( attributes ).find_object_data( self.xml_data )

				}
			rescue

				# the child object was not found in the specified timeout
				Kernel::raise MobyBase::SyncTimeoutError.new( "Synchronization timed out (%i) before the defined child object could be found." % timeout_secs )
			end

			self

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # TDriverSyncronization

end # MobyBehaviour
