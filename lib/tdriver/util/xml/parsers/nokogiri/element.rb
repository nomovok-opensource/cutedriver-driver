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

			module Element # behaviour

				include Abstraction 

				def [](value)

					@xml.attributes[ value ]

				end

				def attributes

					@xml.attributes

				end

				def attribute( attr_name )

					(value = @xml.attribute( attr_name )).nil? ? nil : value.to_s

				end

				def children

					@xml.children

				end

				def content

					@xml.content.to_s

				end

				def each( &block )

					@xml.each{ | element | yield( element_object( element ) ) }

				end        

				def eql?( object )

					@xml.content == object.xml.content

				end

				def empty?

					@xml.nil?

				end

				def inner_xml

					@xml.inner_html.to_s

				end

				def xpath( xpath_query, *args, &block )

					nodeset_object( @xml.xpath( xpath_query, *args, &block ) )

				end

				def replace( other )

					@xml.replace( other.xml )

				end

				def add_previous_sibling( other )

					@xml.add_previous_sibling( other.xml )

				end

				def remove

					@xml.remove

				end

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end # Element

		end # Nokogiri

	end # XML

end # MobyUtil
