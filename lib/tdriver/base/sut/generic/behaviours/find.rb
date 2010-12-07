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

# Find behaviour 
# Methods for finding test objects on the suttest objet state
module MobyBehaviour

	# == description
	# This module contains generic find behaviour
	#
	# == behaviour
	# GenericFind
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
	module Find   

		include MobyBehaviour::Behaviour

		# == description
		# Finds a child test_object given its name and type and returns it as a reference 
		#
		# == arguments
		# attributes
		#  Hash
		#   description: one or more attributes defining the rules for the test object search. Must not be empty.
		#   example: { :name => 'oneButton' }
		#   default: {}
		#
		# == returns
		# MobyBase::TestObject
		#  description: found test object
    #  example: -
		#
		# == exceptions
		# TypeError
		#  description: Wrong argument type %s for attributes (expected Hash)
		# 
		# ArgumentError
		#  description: Attributes hash must not be empty
		# 
		# == info
		#  Same as calling child method.
		def find ( attributes = {} )

			begin

        attributes.check_type( Hash, "Wrong argument type $1 for attributes (expected $2)" )
        
        attributes.not_empty( 'Attributes hash must not be empty' )

				#raise ArgumentError.new( 'Attributes hash must not be empty' ) if attributes.empty?
        
				search_result = child( attributes )

			rescue Exception => e

				MobyUtil::Logger.instance.log "behaviour" , "FAIL;Failed to find test object.;#{id.to_s};sut;{};find;" << ( attributes.kind_of?( Hash ) ? attributes.inspect : attributes.class.to_s )

				Kernel::raise e

			end

			MobyUtil::Logger.instance.log "behaviour" , "PASS;Test object found.;#{id.to_s};sut;{};application;" << attributes.inspect 

			search_result
		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # Find

end # MobyBehaviour
