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

		class Builder

			# Usage:
			#	
			# 	- How to generate simple xml:
			#
			#		MobyUtil::XML::Builder.new{
			#			root{
			#				element(:name => "element_name", :id => "0") {
			#					child(:name => "1st_child_of_element_0", :value => "123" )				
			#					child(:name => "2nd_child_of_element_0", :value => "456 )
			#				}
			#			}
			#		}.to_xml
			#

			attr_accessor :xml

			def initialize( &block )

				@xml = ::Nokogiri::XML::Builder.new( &block )

			end

			def to_xml

				@xml.to_xml

			end

			# support all Nokogiri::XML::Builder class instance methods
			def method_missing( name, *args )

				Kernel::raise NoMethodError.new( "Undefined method '#{ name }' for MobyUtil::XML::Builder class" ) unless @xml.respond_to? name

				@xml.send name.to_sym, *args 

			end

			# enable hooking for performance measurement & debug logging
			MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

		end # Builder

	end # XML

end # MobyUtil
