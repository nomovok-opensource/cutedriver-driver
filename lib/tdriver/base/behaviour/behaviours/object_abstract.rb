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
  # Generic object abstraction class applied to TestObject, Applcation and SUT
  #
  # == behaviour
  # GenericObjectAbstraction
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
	module GenericObjectAbstraction

    # == description
    # Determines if the current object is type of application
    # == returns
    # Boolean
    #  description: Determines is object type of application
    #  example: false
    def application?

      begin

        @type == 'application'

      rescue

        false

      end

    end

    # == description
    # Determines if the current object is type of SUT
    # == returns
    # Boolean
    #  description: Determines is object type of SUT 
    #  example: false
    def sut?

      begin

        @type == 'sut'

      rescue 

        false

      end

    end

    # == description
    # Determines if the current object is type of test object
    # == returns
    # Boolean
    #  description: Determines is object type of test object
    #  example: false
    def test_object?

      begin

        kind_of?( MobyBase::TestObject )

      rescue

        false

      end

    end

	end # GenericObjectAbstraction

end # MobyBehaviour
