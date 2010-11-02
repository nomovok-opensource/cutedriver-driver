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
  # Defines methods for verification of sut and test object state 
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
  # *;sut
  #
	module Verification

		include MobyBehaviour::Behaviour

		# == description
		# Checks if a child test object matching the given criteria can be found on the sut
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
		# ArgumentError
		#  description: The type argument was not a non-empty String or attributes argument (if provided) was not a Hash
		#
		def test_object_exists?(type, attributes = {} )

			Kernel::raise ArgumentError.new "The type argument must be a non empty String." unless (type.kind_of? String and !type.empty?) 
			Kernel::raise ArgumentError.new "The attributes argument must be a Hash." unless attributes.kind_of? Hash

			#attributes_with_type = {}.merge attributes
			attributes_with_type = attributes.clone
			attributes_with_type[:type] = type
			attributes_with_type.delete(:__logging)

			#translate the symbol values into string using sut's localisation setting
			translate!( attributes_with_type )

			identificator = MobyBase::TestObjectIdentificator.new( attributes_with_type )

			original_logging = MobyUtil::Logger.instance.enabled
			desired_logging = (attributes[:__logging] == nil || attributes[:__logging] == 'false') ? false : true
			MobyUtil::Logger.instance.enabled = false      


			begin

				self.child( attributes_with_type )
				MobyUtil::Logger.instance.enabled = desired_logging
				MobyUtil::Logger.instance.log "behaviour" , "PASS;Test object of type #{type} with attributes #{attributes.inspect} was found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"

			rescue MobyBase::MultipleTestObjectsIdentifiedError

				MobyUtil::Logger.instance.enabled = desired_logging
				MobyUtil::Logger.instance.log "behaviour" , "PASS;Multiple objects of type #{type} with attributes #{attributes.inspect} were found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"
				return true

			rescue MobyBase::TestObjectNotFoundError

				MobyUtil::Logger.instance.enabled = desired_logging
				MobyUtil::Logger.instance.log "behaviour" , "FAIL;Test object of type #{type} with attributes #{attributes.inspect} was not found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"
				return false    

			rescue Exception => e

				MobyUtil::Logger.instance.enabled = desired_logging
				MobyUtil::Logger.instance.log "behaviour" , "FAIL;Test object of type #{type} with attributes #{attributes.inspect} was not found.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s : ''};test_object_exist;"
				Kernel::raise e

			ensure

				MobyUtil::Logger.instance.enabled = original_logging

			end

			return true

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # module VerificationBehaviour

end # module MobyBase
