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
  # Generic methods for test object and SUT composition
  #
  # == behaviour
  # GenericObjectComposition
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
	module ObjectComposition

		include MobyBehaviour::Behaviour

		# The parent attribute accessor is deprecated, parent_object() should be used instead.
		#def parent
		
		#  $stderr.puts "#{ caller(0).last.to_s } warning: TestObject#parent is deprecated, please use TestObject#parent_object instead."
		#  @parent
		  
		#end

    # == nodoc
		# Adds a object as a parent of this object
		# === params
		# parent_object Object to be added
		# === returns 
		# ?
		# === raises
		def add_parent( parent_object )

      warn("Warning: Deprecated method, use store to @parent instead of using this method") 

			@parent = parent_object

		end

    # == nodoc
		# removes association to parent object from self
		# === params
		# none
		# === returns 
		# ?
		def remove_parent()

      warn("Warning: Deprecated method, set @parent to nil instead of using this method") 

			@parent = nil

		end

    # == nodoc
		# Adds a test object as a child of this object
		# === params
		# new_child_object:: Object to be added
		# === returns 
		# ?
		# === raises
		def add_child( new_child_object ) 

      warn("Warning: Deprecated method, use @child_object_cache.add_object instead of this method")

			@_child_object_cache.merge!( new_child_object.hash => new_child_object )

		end

    # == nodoc
		# Removes target_child_object from the Set of child objects
		# === params
		# target_test_object:: TestObject to be removed
		# === returns 
		# ?
		# === raises
		def remove_child( target_child_object )

      warn("Warning: Deprecated method, use @child_object_cache.add_object instead of this method")

			@_child_object_cache.delete( target_child_object.hash )

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ObjectComposition

end # MobyBehaviour
