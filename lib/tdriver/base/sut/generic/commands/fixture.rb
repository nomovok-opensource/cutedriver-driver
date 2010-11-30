############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
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



module MobyCommand

  class Fixture < MobyCommand::CommandData

	attr_accessor :params
	
	
	# == description
	# Fixture command holds the required parameters to execute a fixture operation in the target.
	#
	# == arguments
	# params
	#  Hash
	#   description: 
	#    Hash for holding the parameters need by the fixture operation.
	#    Example: {:application_id => "", :object_id => "", :object_type => "", :name => nil, :command_name => nil, :parameters => {}, :async => false)}
	#
	def initialize(params)

	  @params = params

	end
	
  end # Fixture

end # MobyCommand
