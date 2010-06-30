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

	module XML

		module Nokogiri

			module Nodeset # behaviour

				include Abstraction 

				def []( node )

					element_object( @xml[ node ] )

				end

				def each( &block )

					@xml.each{ | element | 

						yield( element_object( element ) ) 

					}

				end

				def collect( &block )

					@xml.collect{ | element | 

						yield( element_object( element ) ) 

					}

				end

				def empty?

					@xml.empty?

				end

				def first

					element_object( @xml.first )

				end

				def last

					element_object( @xml.last )

				end
				
				def length

					@xml.length

				end
		
				# aliases for length method
				alias size length

				alias count length
		
				def to_a
					
					a = []
					@xml.each do |element|
						a << element_object( element )
					end
					a
					
				end
				
				def delete( node )
					@xml.each do |element|
						if (node.xml.content == element.content)
							@xml.delete(element)
							break
						end
					end
					
				end

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end # Nodeset

		end # Nokogiri

	end # XML

end # MobyUtil
