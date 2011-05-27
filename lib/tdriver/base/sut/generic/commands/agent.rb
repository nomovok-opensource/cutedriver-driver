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

  class AgentCommand < MobyCommand::CommandData

	  attr_accessor :parameters
		
	  # == description
	  # Agent command holds the required parameters to execute a agent information queries in the target.
	  # == arguments
	  # params
	  #  Hash
	  #   description: Hash for holding the parameters need by the agent information query operation.
	  #   example: {}
	  def initialize( parameters = {} )

      parameters.check_type Hash, 'wrong argument type $1 for agent service command object (expected $2)'

	    @parameters = parameters

	  end
	
  end # AgentCommand

end # MobyCommand
