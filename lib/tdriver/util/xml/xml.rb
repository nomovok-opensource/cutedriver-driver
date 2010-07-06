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

		# default values
		#@@parser = MobyUtil::XML::LibXML 
		@@parser = MobyUtil::XML::Nokogiri

		# TODO: Documentation
		def self.current_parser

			@@parser

		end

		# TODO: Documentation
		def self.current_parser=( value )

			@@parser = value

		end

		# Create XML Document object by parsing XML from string
		#
		# Usage: MobyUtil::XML.parse_string('<root>value</root>') 
		#  ==> Returns XML document object; default xml parser will be used. 
		#
		# == params
		# xml_string:: String containing XML
		# parser:: Pointer to XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		def self.parse_string( xml_string )

			begin

				MobyUtil::XML::Document.new().extend( @@parser::Document ).tap{ | document | 

					document.xml = document.parse( xml_string ) 

					document.parser = current_parser

				}

			rescue Exception => exception

				Kernel::raise MobyUtil::XML::ParseError.new( "%s (%s)" % [ exception.message, exception.class ] )


			end

		end

		# Create XML Document object by parsing XML from file
		#
		# Usage: MobyUtil::XML.parse_file('xml_dump.xml') 
		#  ==> Returns XML document object; default xml parser will be used. 
		#
		# == params
		# filename:: String containing path and filename of XML file.
		# parser:: Pointer to XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		# IOError:: File '%s' not found    
		def self.parse_file( filename )    

			# raise exception if file not found
			Kernel::raise IOError.new( "File '%s' not found" % filename ) unless File.exist?( filename )

			self.parse_string( IO.read( filename ), current_parser )

		end

		# Usage:
		#	
		# 	- How to generate simple xml:
		#
		#		MobyUtil::XML.build{
		#			root{
		#				element(:name => "element_name", :id => "0") {
		#					child(:name => "1st_child_of_element_0", :value => "123" )				
		#					child(:name => "2nd_child_of_element_0", :value => "456" )
		#				}
		#			}
		#		}.to_xml
		#
		def self.build( &block )

			begin

				MobyUtil::XML::Builder.new.extend( @@parser::Builder ).tap{ | builder | 

					builder.build( &block )

				}

			rescue Exception => exception

				Kernel::raise MobyUtil::XML::BuilderError.new( "%s (%s)" % [ exception.message, exception.class ] )


			end
			
		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # XML

end # MobyUtil
