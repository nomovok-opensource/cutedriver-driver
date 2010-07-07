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

$KCODE = 'u'

# Following line to prevent Object#id Warnings
Object.send :undef_method, :id if Object.respond_to?( :id )

# for debugging to see every occured exception
#def Kernel::raise( *args )
#	p args.first, args.first.backtrace, caller
#	super
#end

require File.expand_path( File.join( File.dirname( __FILE__ ), 'loader' ) )

class TDriver

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

		# if given arguments is type of Symbol expect is as SUT id
		sut_attributes = { :Id => sut_attributes } if sut_attributes.kind_of? Symbol

		Kernel::raise ArgumentError.new( "Wrong argument type '%s' (Expected Hash)" % sut_attributes.class ) unless sut_attributes.kind_of?( Hash )
		Kernel::raise ArgumentError.new( "Sut id not given!" ) unless sut_attributes.has_key?( :Id )

		MobyBase::SUTFactory.instance.make( sut_attributes[ :Id ] )
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

		# if given arguments is type of Symbol expect is as SUT id
		sut_attributes = { :Id => sut_attributes } if sut_attributes.kind_of? Symbol

		Kernel::raise ArgumentError.new( "Wrong argument type '%s' (Expected Hash)" % sut_attributes.class ) unless sut_attributes.kind_of?( Hash )
		Kernel::raise ArgumentError.new( "Sut id not given!" ) unless sut_attributes.has_key?( :Id )

		MobyBase::SUTFactory.instance.disconnect_sut( sut_attributes[ :Id ] )
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

		# if given arguments is type of Symbol expect is as SUT id
		sut_attributes = { :Id => sut_attributes } if sut_attributes.kind_of? Symbol

		Kernel::raise ArgumentError.new( "Wrong argument type '%s' (Expected Hash)" % sut_attributes.class ) unless sut_attributes.kind_of?( Hash )
		Kernel::raise ArgumentError.new( "Sut id not given!" ) unless sut_attributes.has_key?( :Id )

		MobyBase::SUTFactory.instance.reboot_sut( sut_attributes[ :Id ] )

	end

	# Wrapper for SUT functionality. For documentation, please see TDriver::connect_sut
	def self.sut( *args )

		self.connect_sut( *args )

	end

	# Wrapper for MobyUtil::Parameter.configured_suts to retrieve all configured sut names
	def self.suts

		MobyUtil::Parameter.configured_suts

	end

	# Wrapper for MobyUtil::ParameterUserAPI class with methods e.g. [] and []=, files and load_xml etc.
	def self.parameter

		@matti_parameter_instance || ( @matti_parameter_instance = MobyUtil::ParameterUserAPI.instance )

	end

	def self.logger

		@tdriver_logger_instance || ( @tdriver_logger_instance = MobyUtil::Logger.instance )

	end

	# enable hooking for performance measurement & debug logging
	MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )


end # TDriver

# Enable logging engine
MobyUtil::Logger.instance.enable_logging()

