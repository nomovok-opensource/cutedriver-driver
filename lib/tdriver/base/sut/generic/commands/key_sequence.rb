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

module MobyCommand

	class KeySequence < MobyCommand::CommandData

		attr_accessor :id

		# Constructor to KeySequence
		# == params
		# key_symbol:: (optional) Symbol of key to be added to sequence if given.
		# type_symbol:: (optional) Symbol of keypress type of key if given, otherwise use default.
		# == returns
		# Instance of KeySequence
		def initialize( key_symbol = nil, type_symbol = :ShortPress )
			#TODO: Review comment (OR): @sequence -> @_sequence?
			@sequence = [] # Array.new( 0 )
			#@_sut = sut
			self.append!( key_symbol, type_symbol ) unless key_symbol.nil?
		end

		# Function to append a keypress with type to KeySequence.sequence array
		# == params
		# key_symbol:: Symbol of key to be appended to sequence.
		# type_symbol:: (optional) Symbol of keypress type of key if given, otherwise use default.
		# == returns
		# self 
		def append!( key_symbol, type_symbol = :ShortPress )
			@sequence.push({:value => key_symbol, :type => type_symbol})    
			self       
		end

		# Function to repeat last added keypress in sequence unless count is less than one or keypress sequence is empty  
		# == params
		# count:: times of key repeated, default is one   
		# == returns
		# self
		# == raises
		# ArgumentError:: Fixnum expected as argument
		# ArgumentError:: Positive value expected as argument
		# IndexError:: Not allowed when empty key sequence
		def times!( count = 1 )

      # verify count argument type
			#Kernel::raise ArgumentError.new("Fixnum expected as argument") if count.class != Fixnum
      count.check_type( Fixnum, "Wrong argument type $1 for times count (expected $2)" )

      # verify that count is positive number
			Kernel::raise ArgumentError.new( "Positive value expected for times count (got #{ count })" ) if count.negative?

      # verify that @sequence is not empty
			#Kernel::raise IndexError.new( "Not allowed when empty key sequence" ) if @sequence.size == 0
			Kernel::raise IndexError.new( "Unable to multiply last given key due to key sequence is empty" ) if @sequence.empty?

			count.times do | iteration |
			
				@sequence.push @sequence.fetch( -1 ) unless iteration == 0 

			end

			self
			
		end
				
		# Returns the stored sequence as an Array with Hash elements having :value and :type keys for each press.
		# == returns
		# Array:: Stored key sequence
		def get_sequence
		  @sequence
		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # KeySequence

end # MobyCommand
