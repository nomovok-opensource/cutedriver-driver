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

  class FixturePluginService

    # remove all public methods
    instance_methods.each{ | method | 

      undef_method( method ) unless method =~ /^__|^(methods|inspect|to_s|class|nil?|extend)/ 

    }

    # TODO: document me
    def initialize( options = {} )

      # verify that options is type of hash
      options.check_type Hash, 'wrong argument type $1 for fixture service options (expected $2)'

      # verify that name is defined in options hash
      options.require_key :name

      options.require_key :arguments

      options.require_key :target

      options.require_key :configuration

      # store given options
      @options = options
      
      # store caller backtrace
      @caller = caller

      self

    end      

    def method_missing( fixture_method, arguments = {} )

      begin

        arguments.check_type Hash, 'wrong argument type $1 for fixture method arguments (expected $2)'

        result = nil

        _async = @options[ :arguments ][ :async ].true?

        _target = @options[ :target ]

        _fixture_name = @options[ :name ].to_s

        _fixture_method = fixture_method.to_s

        _sut = _target.sut

        params = { :name => _fixture_name.to_s, :command_name => _fixture_method, :parameters => arguments, :async => _async }

        if _target.sut?

          params.merge!( :application_id => nil, :object_id => _target.id, :object_type => :Application )

        else

          params.merge!( :application_id => _target.get_application_id, :object_id => _target.id, :object_type => _target.attribute( 'objectType' ).to_sym )

        end

        result = _sut.execute_command( MobyCommand::Fixture.new( params ) )

      rescue

        $logger.behaviour "FAIL;Failed when calling fixture #{ @options[:arguments ].inspect } with name #{ _fixture_name.inspect }, method #{ _fixture_method.inspect } and parameters #{ arguments.inspect }.;#{ _target.id.to_s };sut;{};fixture;"

        raise MobyBase::BehaviourError.new("Fixture", "Failed when calling fixture #{ @options[:arguments ].inspect } with name #{ _fixture_name.inspect }, method #{ _fixture_method.inspect } and parameters #{ arguments.inspect }")

      end

      $logger.behaviour "PASS;The fixture command (#{ @options[ :arguments ]}) was executed successfully with name #{ _fixture_name.inspect }, method #{ _fixture_method.inspect } and parameters #{ arguments.inspect }.;#{ _target.id.to_s };sut;{};fixture;"

      result

    end

  end # FixturePluginService

  module FixtureSetupFunctions
  
    def []( name )
    
      name.check_type [ String, Symbol ], 'wrong argument type $1 for fixture name (expected $2)'

      @target.parameter[ :fixtures ].fetch( name.to_sym ){ | name | 

        raise MobyBase::BehaviourError.new( "Fixture", "Failed to execute fixture due to #{ name.to_s.inspect } not found for #{ @target.sut.id.inspect }" )
      
      }
          
    end
  
    def []=( name, plugin )
    
      name.check_type [ String, Symbol ], 'wrong argument type $1 for fixture name (expected $2)'
    
      plugin.check_type [ String ], 'wrong argument type $1 for fixture pluin name (expected $2)'
    
      name = name.to_sym
      
      plugin = plugin.to_s
    
      # create fixtures configuration hash unless already exists
      @target.parameter[ :fixtures ] = {} unless @target.parameter.has_key?( :fixtures )
    
      if @target.parameter[ :fixtures ].has_key?( name )
        
        # retrieve existing fixture configuration
        fixture_hash = @target.parameter[ :fixtures ][ name ]
      
      else

        # fixture was not found from hash, add sut environment to hash
        fixture_hash = { :env => @target.instance_variable_get(:@environment) }
              
      end
      
      # store plugin name to hash
      fixture_hash[ :plugin ] = plugin
    
      # store fixture settings to fixtures configuration hash
      @target.parameter[ :fixtures ][ name ] = fixture_hash

      self
    
    end
  
  end

  class FixtureService

    # remove all public methods
    instance_methods.each{ | method | 

      undef_method( method ) unless method =~ /^__|^(methods|inspect|to_s|class|nil?|extend)/ 

    }

    # TODO: document me
    def initialize( options = {} )

      # verify that options is type of hash
      options.check_type Hash, 'wrong argument type $1 for fixture service options (expected $2)'

      # verify that target object is defined in options hash
      options.require_key :target

      # store given options
      @options = options

      # store sut variable
      @target = options[ :target ]
      
      # store caller backtrace
      @caller = caller

      # extend with fixture setup functions if self is kind of sut 
      extend FixtureSetupFunctions if @target.sut?
      
      self

    end      

    def method_missing( name, arguments = {} )

      arguments.check_type Hash, 'wrong argument type $1 for fixture options (expected $2)'

      _fixtures = $parameters[ @target.sut.id ][ :fixtures, {} ]

      if _fixtures.has_key?( name )

        FixturePluginService.new( :target => @target, :name => name, :arguments => arguments, :configuration => _fixtures[ name ] )

      else

        $logger.behaviour "FAIL;Failed to execute fixture due to #{ name.inspect } not foudn for #{ @target.sut.id.inspect }.;#{ @target.id.to_s };sut;{};fixture;"

        raise MobyBase::BehaviourError.new( "Fixture", "Failed to execute fixture due to #{ name.to_s.inspect } not found for #{ @target.sut.id.inspect }" )

      end

    end
    
  end # FixtureService

end # TDriver
