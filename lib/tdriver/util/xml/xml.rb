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
		#@@default_parser = MobyUtil::XML::LibXML 
		@@default_parser = MobyUtil::XML::Nokogiri

		# Create XML Document object by parsing XML from file
		#
		# Usage: MobyUtil::XML.parse_file('xml_dump.xml') 
		#  ==> Returns XML document object; default xml parser will be used. 
		# Usage: MobyUtil::XML.parse_file('xml_dump.xml', MobyUtil::XML::LibXML)
		#  ==> Returns XML document object; uses LibXML as XML parser.
		#
		# == params
		# filename:: String containing path and filename of XML file.
		# parser:: Pointer to XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		# IOError:: File '%s' not found    
		def self.parse_file( filename, parser = @@default_parser )    

			# raise exception if file not found
			Kernel::raise IOError.new( "File '%s' not found" % filename ) unless File.exist? filename

			self.document_object( IO.read( filename ), parser )

		end

		# Create XML Document object by parsing XML from string
		#
		# Usage: MobyUtil::XML.parse_file('<root>value</root>') 
		#  ==> Returns XML document object; default xml parser will be used. 
		# Usage: MobyUtil::XML.parse_file('<root>value</root>', MobyUtil::XML::LibXML)
		#  ==> Returns XML document object; uses LibXML as XML parser.
		#
		# == params
		# xml_string:: String containing XML
		# parser:: Pointer to XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		def self.parse_string( xml_string, parser = @@default_parser )

			self.document_object( xml_string, parser )

		end

	private

		# Private method to create MobyUtil::XML:Document with given parser
		def self.document_object( xml_string, parser )

			begin

				MobyUtil::XML::Document.new().extend( parser::Document ).tap{ | doc | doc.xml = doc.parse( xml_string ); doc.parser = parser; }

			rescue Exception => exception

				Kernel::raise MobyUtil::XML::ParseError.new( "%s (%s)" % [ exception.message, exception.class ] )


			end

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # XML

end # MobyUtil
