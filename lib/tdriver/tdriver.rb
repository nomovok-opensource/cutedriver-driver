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

# initializing TDriver
$TDRIVER_INITIALIZED = false

# unicode support
$KCODE = 'u'

# prevent Object#id Warnings
Object.send( :undef_method, :id ) if Object.respond_to?( :id )

# TODO: document me
def require_relative( file )

  # require with full expanded path
  require File.expand_path( File.join( File.dirname( caller.first.scan( /(.*?):/ ).to_s ), file ) )

end

# load all required components
require File.expand_path( File.join( File.dirname( __FILE__ ), 'loader.rb' ) )

module TDriver

	# Function to create and (or if already created re-) connect SUT object 
	# === params
	# hash:: Defines SUT type, identification attributes etc. 
	#   :type:: Valid values are :S60 (for Series 60) and :QT (for QT)
	#   :id:: Valid id that can be matched in tdriver_parameters.xml
	# === raises
	# ArgumentError:: Wrong argument Type '%s' (Expected Hash)
	# ArgumentError:: SUT type not defined
	# ArgumentError:: SUT type '%s' not supported
	# ArgumentError:: Sut id not given
	# MobyUtil::ParameterFileNotFoundError:: if paramter file 'tdriver_home'/tdriver_parameters.xml is not found
	# === returns
	# Object:: Object that SutFactory returns 
	# === example
	#  @sut = TDriver.connect_sut(:Id =>'sut_qt') # for qt, id in configuration file sut_qt
	def self.connect_sut( sut_attributes = {} )

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
	def self.disconnect_sut( sut_attributes = {} )

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
	#  @sut = TDriver.reboot_sut(:Id =>'sut_qt') # for Qt, should be connected already   
	def self.reboot_sut( sut_attributes = {} )

		MobyBase::SUTFactory.instance.reboot_sut( sut_attributes )

	end

	# Wrapper for SUT functionality. For documentation, please see TDriver::connect_sut
	def self.sut( *args )

		self.connect_sut( *args )

	end

	# Wrapper for MobyUtil::Parameter.configured_suts to retrieve all configured sut names
	def self.suts

		$parameters.configured_suts

	end

	# Wrapper for MobyUtil::ParameterUserAPI class with methods e.g. [] and []=, files and load_xml etc.
	def self.parameter( *arguments )

    if arguments.count == 0
    
      $parameters_api
          
    else
    
      $parameters_api[ *arguments ]
    
    end

	end

	# Wrapper for MobyUtil::Logger class
	def self.logger

    $logger
    
	end

	# enable hooking for performance measurement & debug logging
	TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

end # TDriver

# enable logging engine
$logger.enable_logging

# initialization done, everything is ready
$TDRIVER_INITIALIZED = true
