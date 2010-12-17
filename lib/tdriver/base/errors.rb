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


module MobyBase

	class Error

		@@errors = {
			:WrongArgumentType => {:type => "ArgumentError", :text => "Wrong argument type %s (Expected %s)"},
			:WrongArgumentTypeFor => {:type => "ArgumentError", :text => "Wrong argument type %s for %s (Expected %s)"},
			:ArgumentSymbolExpected => {:type => "ArgumentError", :text => "Symbol %s expected in argument(s)"}, 
			:InvalidStringLengthFor => {:type => "ArgumentError", :text => "Invalid string length (%i) for %s (Expected %s)"},
			:BehaviourErrorOccured => {:type => "RuntimeError", :text => "%s method failed with message: %s. Debug info: %s"}
		}

		def self.raise( error_id, *params )

			if @@errors.has_key?( error_id )

				error_type = eval(@@errors[ error_id ][ :type ])
				error_text = @@errors[ error_id ][ :text ]

				# Replace %s to given parameters
				message = error_text.gsub( /\%[-]*\d*[disxX]/ ) { | match | ( params.size > 0 ) ? "#{ match }" % params.shift : match }

			else

				# Raise ArgumentError if given id is not defined in @@error_base hash table
				error_type = ArgumentError
				message = "No error found for ID '%s' (Parameters: %s)" % [ error_id, params.join( ", " ) ]

			end

			error = error_type.new( message )
			Kernel::raise error
		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end

	# TODO: document
	class MobyStandardError < StandardError
		# Construct a new error, optionally passing in a message
		def initialize ( message = nil ); super( message ); end
	end

	# TODO: document
	class TestObjectNotVisibleError < MobyStandardError; end;

	# TODO: document
	class TestObjectNotFoundError < MobyStandardError; end;

	# TODO: document
	class MultipleTestObjectsIdentifiedError < MobyStandardError; end;

	# TODO: document
	class MultipleAttributesFoundError < MobyStandardError; end;

	# TODO: document
	class AttributeNotFoundError < MobyStandardError; end;

	# TODO: document
	class TestObjectNotInitializedError < MobyStandardError; end;

	# TODO: document
	class FileNotFoundError < MobyStandardError; end;

	# TODO: document
	class TestObjectIdentificatorError < MobyStandardError; end;

	#Raised when a method is called with an invalid parameter(eg. wrong type, impossible value, nil)
	class InvalidParameterError < MobyStandardError; end;

	# This error should be raised when verification results were not as expected
	class VerificationError < MobyStandardError; end;

	# This verification error should overwrite standard verification procedure and
	# fail immediately
	class ContinuousVerificationError < VerificationError; end;

	# This error should be raised to indicate that a synchronization timeout has elapsed without 
	# synchronization conditions having been met.
	class SyncTimeoutError < MobyStandardError; end;

	class ControllerError < MobyStandardError; end; #def initialize ( msg = nil ); super( msg ); end; end # class

	class ControllerNotFoundError < MobyStandardError; end;

	class CommandNotFoundError < MobyStandardError; end


	# TODO: document
	class MobyCustomError < StandardError
		attr_reader :message
		def initialize( message = "" )
			# get backtrace from error
			tmp_trace = ( ( $!.nil? ) ? [] : $!.backtrace ) 
			# add caller method to backtrace
			set_backtrace( ( ( caller( 2 ).nil? ) ? tmp_trace : tmp_trace.unshift( caller( 2 ).first[ /(.+):in/, 1 ] ) ) )
			@message = message << ( $!.nil? ? "" : ". Exception: #{ $!.message }" )
			super
		end
	end

	# TODO: document
	class BehaviourError < MobyCustomError
		def initialize ( method_name = nil, description = nil )
			super( "%s failed. %s" % [ method_name, description ] )
		end
	end

	# TODO: document
	class ApplicationNotAvailableError < MobyStandardError; end;

end # MobyBase
