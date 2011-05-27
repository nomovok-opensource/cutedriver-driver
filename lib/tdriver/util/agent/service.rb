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

module TDriver

  class AgentService

=begin
    # remove all public methods
    instance_methods.each{ | method | 
      undef_method( method ) unless method =~ /^__|^(methods|inspect|to_s|class|nil?|extend)/ 
    }
    
    # required by commands method to list available services
    private :methods
=end
    
    # TODO: document me
    def initialize( options = {} )

      # verify that options is type of hash
      options.check_type Hash, 'wrong argument type $1 for AgentCommandService options (expected $2)'

      # verify that sut is defined in options hash
      options.require_key :sut

      sut = options[ :sut ]

      MobyBase::BehaviourFactory.instance.apply_behaviour!( 
        :object       => self,
        :object_type  => [ 'AgentCommandService' ],
        :env          => [ '*', *sut.environment.to_s.split(";") ],
        :input_type   => [ '*', *sut.input.to_s.split(";") ],
        :version      => [ '*', *sut.ui_version.to_s.split(";") ]
      )
    
      # store given options
      @options = options

      # store sut variable
      @sut = sut
      
      # store caller backtrace
      @caller = caller

    end
    
    # TODO: document me
    def commands
      
      class << self

        # retrieve all public methods
        instance_methods( false ).select{ | name | true unless name =~ /^__|^commands$/ }      

      end
    
    end

  private

    # TODO: document me
    def execute_command( command_data_object )

      begin

        # execute command
        @sut.__send__( :execute_command, command_data_object )

      rescue MobyBase::ControllerNotFoundError

        # raise exception if sut doesn't have controller for the command data object 
        raise NotImplementedError, "Agent command #{ command_data_object.parameters[ :command ].inspect } is not supported on #{ @sut.id.inspect }", @caller

      end
      
    end

  private

    # TODO: document me      
    def method_missing( id, *args )
    
      # raise exception if unknown command or not supported by sut 
      raise RuntimeError, "agent command #{ id.inspect } not supported by #{ @options[ :sut ].id }", caller
    
    end
                    
  end # AgentCommandService

end # TDriver
