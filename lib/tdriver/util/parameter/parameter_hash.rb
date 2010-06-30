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


module MobyUtil

	class ParameterHash < Hash

		def initialize( hash = {} )

			Kernel::raise ArgumentError.new( "Unexpected argument type %s, expecting Hash or ParameterHash" % [ hash.class ] ) unless [ Hash, ParameterHash ].include?( hash.class )

			merge!( 

				hash.empty? ? hash : convert_hash( hash )

			)

		end

		def convert_hash( hash )

			hash.kind_of?( ParameterHash ) ? hash : ParameterHash[ hash.collect{ | key, value | [ key, value.kind_of?( Hash ) ? convert_hash( value ) : value ] } ]

		end

		def []( key, *default, &block )

			fetch( key ){ 

				if default.empty?

					Kernel::raise ParameterNotFoundError.new( "Parameter %s not found." % [ key ] ) unless block_given?

					# yield with key if block given
					result = yield( key )

				else
					Kernel::raise ArgumentError.new( "Only one default value allowed for parameter (%s)" % [ default.join(", ") ] ) unless default.size == 1

					result = default[ 0 ]

				end

				result.kind_of?( Hash ) ? convert_hash( result ) : result

			}

		end

		def []=( key, value )

			Kernel::raise ParameterNotFoundError.new( "Parameter key nil is not valid." ) unless key

			store( key, ( value.kind_of?( Hash ) ? convert_hash( value ) : value ) )

		end

		# Merge this Hash with another, primary Hash. Any values found in the other hash will overwrite local values and any Hash values will be recursively merged.
		def merge_with_hash!( primary_hash )

			raise ArgumentError.new( "Unable to merge, the other Hash was not a Hash, it was of type \"" + primary_hash.class.to_s + "\"." ) unless primary_hash.kind_of?( Hash )

			primary_hash.each_pair do | key, value |

				if ( self.has_key?( key ) && self[ key ].kind_of?( Hash ) ) and primary_hash[ key ].kind_of?( Hash )

					self[ key ].merge_with_hash!( value )

				else

					self[ key ] = value

				end

			end

			self
		  
	        end

		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # ParameterHash

end # MobyUtil
