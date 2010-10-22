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
  # Generic methods for applying behaviours to target object
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
	module ObjectBehaviourComposition

  public

    # == description
    # Apply all behaviour modules to target object which meets the given rules. Target object can be either type of "sut", "application" or "*" (any test object). 
    # == tables
    # apply_behaviour_table
    #  title: Hash table details
    #  |Key|Description|Example|Required|
    #  |:object_type| Rule for object type(s). In following example all generic test object and application specific behaviours are accepted. | ["*", "application"] | Yes |
    #  |:sut_type| Rule for SUT type(s). In following example all non-SUT specific and QT specific behaviours are applied. | ["*", "QT"] | Yes |
    #  |:input_type| Rule defining for SUT input type(s). In following example all SUT input types and touch screen specific behaviours are applied. | ["*", "touch"] | Yes |
    #  |:version| Rule for SUT version(s). In following example all all SUT versions and SUT QT v1.0 specific behaviours are applied. | ["*", "1.0"] | Yes |
    #
    # == arguments
    # rules
    #  Hash
    #   description: Target object's SUT, type and version requirements  
    #   example: { :version=>["*", "1.0"], :object_type=>["*", "application"], :sut_type=>["*", "QT"], :input_type=>["*", "touch"] }
    #
    # == returns
    # Array
    #  description: Array of applied behaviour module indexes (Fixnum) 
    #  example: [0, 3, 4, 6, 7, 8, 9]
		def apply_behaviour!( rules )

			sut = ( sut = self ).kind_of?( MobyBase::SUT ) ? sut : sut.sut 

			MobyBase::BehaviourFactory.instance.apply_behaviour!( { :sut_type => [ '*', sut.ui_type ], :version => [ '*', sut.ui_version ] }.merge( rules ).merge( { :object => self } ) )

		end

  private

		# behaviour specific initialization
		def self.extended( target )

			target.instance_exec{

				# array of extended behaviours to target object
				@object_behaviours = []

			}

		end
		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )
	
	end # ObjectBehaviourComposition

end # MobyBehaviour
