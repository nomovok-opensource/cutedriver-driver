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
  # Agent specific commands
  #
  # == behaviour
  # AgentCommands
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
  # AgentCommandService
  module AgentCommands

    include MobyBehaviour::Behaviour

    # == nodoc
    # == description
    # Queries version of used agent 
    #
    # == arguments
    # == returns
    # String
    #  description: version number in String format
    #  example: "1.3"
    #
    # == exceptions
    # 
    # == info
    # See SUT#agent method
    def version
      
      # execute command/model by using sut controller
      execute_command( 

        # model
        MobyCommand::AgentCommand.new( :command => :version ) 

      )
      
    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # AgentCommands

end # MobyBehaviour
