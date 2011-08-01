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

# Framework main file that needs to be included in tests.
# Used for setting up testing environment, eg
# 
#  require File.join( ENV['TDRIVER_HOME'] , 'tdriver.rb' )
#  @sut = TDriver.sut(:Id =>'sut_qt') # for Qt, id in configuration file sut_qt
#
# Please see class documentation for more info

# initializing tdriver
$TDRIVER_INITIALIZED = false

# unicode support for 1.8.7
$KCODE = 'u' if RUBY_VERSION < "1.9"

# prevent Object#id Warnings
Object.send( :undef_method, :id ) if Object.respond_to?( :id )

# load all required components
require File.expand_path( File.join( File.dirname( __FILE__ ), 'loader.rb' ) )

module TDriver

  class << self

    # Function to create and (or if already created re-) connect SUT object 
    # === params
    # hash:: Defines SUT type, identification attributes etc. 
    #   :id:: Valid id that can be matched in tdriver_parameters.xml
    # === raises
    # ArgumentError:: Wrong argument Type '%s' (Expected Hash)
    # ArgumentError:: SUT type not defined
    # ArgumentError:: SUT type '%s' not supported
    # ArgumentError:: Sut id not given
    # MobyUtil::ParameterFileNotFoundError:: if paramter file (tdriver_parameters.xml in TDriver home directory) is not found
    # === returns
    # Object:: Object that SutFactory returns 
    # === example
    #  @sut = TDriver.connect_sut(:Id =>'sut_qt') # for qt, id in configuration file sut_qt
    def connect_sut( sut_attributes = {} )

      MobyBase::SUTFactory.instance.make( sut_attributes )

    end

    # Function to disconnect SUT object.  
    # === params
    # hash:: Defines SUT type, identification attributes etc. 
    #   :id:: Valid id that can be matched in tdriver_parameters.xml and is already connected
    # === raises
    # ArgumentError:: Not connected to device 'id' if not connected at all / device already disconnected
    # ArgumentError:: Sut id not given
    # === returns
    # Object:: SUT object 
    # === example
    #  @sut = TDriver.disconnect_sut(:Id =>'sut_qt') # for qt, should be connected already
    def disconnect_sut( sut_attributes = {} )

      MobyBase::SUTFactory.instance.disconnect_sut( sut_attributes )

    end

    # Function to reboot SUT object.  
    # === params
    # hash:: Defines SUT type, identification attributes etc. 
    #   :id:: Valid id that can be matched in tdriver_parameters.xml and is already connected
    # === raises
    # ArgumentError:: Not connected to device 'id' if not connected at all / device already disconnected
    # ArgumentError:: Sut id not given
    # === example
    #  @sut = TDriver.reboot_sut(:Id => 'sut_qt') # for Qt, should be connected already   
    def reboot_sut( sut_attributes = {} )

      MobyBase::SUTFactory.instance.reboot_sut( sut_attributes )

    end

    # Wrapper for SUT functionality. For documentation, please see TDriver::connect_sut
    def sut( *args )

      connect_sut( *args )

    end

    # Wrapper for TDriver::Parameter.configured_suts to retrieve all configured sut names
    def suts

      $parameters.configured_suts

    end

    # Wrapper for TDriver::ParameterUserAPI class with methods e.g. [] and []=, files and load_xml etc.
    def parameter( *arguments )

      if arguments.count == 0
      
        $parameters_api
            
      else
      
        $parameters_api[ *arguments ]
      
      end

    end

    # TODO: document me
    def state_object( options )

      # create state object with given options
      MobyBase::StateObject.new( options )

    end
    
    # == nodoc
    # Wrapper for MobyUtil::Logger class
    def logger

      $logger
      
    end

    # == nodoc
    # TODO: document me
    def config_dir

      if ENV['TDRIVER_HOME']
      
        config_dir = ENV['TDRIVER_HOME']
            
      elsif MobyUtil::EnvironmentHelper.windows?
      
        config_dir = "c:/tdriver"
      
      else

        config_dir = "/etc/tdriver"
      
      end
        
      File.expand_path( config_dir )
    
    end
    
    # == nodoc
    # TODO: document me
    def library_dir
    
      File.expand_path( File.dirname( __FILE__ ) )
    
    end

    # == nodoc
    # TODO: document me
    def version

      ENV['TDRIVER_VERSION'] || "unknown"

    end
  
  private

    # TODO: document me
    def initialize_tdriver
    
      # initialize parameters
      $parameters.init

      # enable logging engine
      $logger.enable_logging

      # set xml cache buffer size 
      MobyUtil::XML.buffer_size = $parameters[ :xml_cache_buffer_size, 10 ].to_i

      # load behaviours
      TDriver::BehaviourFactory.init( :path => File.join( config_dir, 'behaviours' ) )

      # initialization done, everything is ready
      $TDRIVER_INITIALIZED = true

    end

  end

  # enable hooking for performance measurement & debug logging
  TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  # initialize TDriver
  initialize_tdriver

end # TDriver
