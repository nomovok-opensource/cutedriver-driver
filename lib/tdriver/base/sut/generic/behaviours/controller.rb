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
  # SUT controller behaviours
  #
  # == behaviour
  # GenericSutController
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
  # sut
  #
	module SutController

		include MobyBehaviour::Behaviour

    # == nodoc
		def execution_order

			@_sutController.execution_order

		end

    # == nodoc
		def execution_order=( order )

			@_sutController.execution_order = order

		end

		# enable hooking for performance measurement & debug logging
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # SutController 

end # MobyBehaviour
