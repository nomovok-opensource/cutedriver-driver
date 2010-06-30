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

	module ObjectBehaviourComposition

		# behaviour specific initialization
		def self.extended( target )

			target.instance_exec{

				# array of extended behaviours to target object
				@object_behaviours = []

			}

		end

		def apply_behaviour!( rules )

			sut = ( sut = self ).kind_of?( MobyBase::SUT ) ? sut : sut.sut 

			MobyBase::BehaviourFactory.instance.apply_behaviour!( { :sut_type => [ '*', sut.ui_type ], :version => [ '*', sut.ui_version ] }.merge( rules ).merge( { :object => self } ) )

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )
	
	end # ObjectBehaviourComposition

end # MobyBehaviour
