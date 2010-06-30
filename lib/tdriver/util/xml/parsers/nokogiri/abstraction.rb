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

			module Abstraction

				def empty?

					@xml.empty?

				end

				def name

					@xml.name

				end

				def nil?

					@xml.nil?

				end

				def size

					@xml.size

				end

				def to_s

					@xml.to_s

				end

			private

				# method to create MobyUtil::XML::Attribute object
				def attribute_object( xml_data )

					MobyUtil::XML::Attribute.new().extend( Attribute ).tap { | attr | attr.xml = xml_data; attr.parser = @parser; }

				end

				# method to create MobyUtil::XML::Element object
				def element_object( xml_data )

					MobyUtil::XML::Element.new().extend( Element ).tap { | element | element.xml = xml_data; element.parser = @parser; }

				end

				def method_missing( method, *args, &block )

					Kernel::raise RuntimeError.new("Method '#{ method.to_s }' is not supported by #{ self.class.to_s } (#{ @parser.to_s })" )

				end

				# method to create MobyUtil::XML::Nodeset object
				def nodeset_object( xml_data )

					MobyUtil::XML::Nodeset.new().extend( Nodeset ).tap { | node | node.xml = xml_data; node.parser = @parser; }

				end

				# enable hooking for performance measurement & debug logging
				MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

			end # Abstraction

 		end # Nokogiri

	end # XML

end # MobyUtil
