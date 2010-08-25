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

		# Get current XML parser
		# == params
		# == return
		# Module:: 
		# == raises
		def self.current_parser

			@@parser

		end

		# Set XML parser to be used
		# == params
		# Module:: 
		# == return
		# nil
		# Document:: XML document object
		# == raises
		def self.current_parser=( value )

			@@parser = value

			nil

		end

		# Create XML Document object by parsing XML from string
		#
		# Usage: MobyUtil::XML.parse_string('<root>value</root>') 
		#  ==> Returns XML document object; default xml parser will be used. 
		#
		# == params
		# xml_string:: String containing XML
		# parser:: XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		def self.parse_string( xml_string )

			begin

				MobyUtil::XML::Document.new( nil, current_parser ).extend( @@parser::Document ).tap{ | document | 

          # parse given string
					document.xml = document.parse( xml_string ) 

				}

			rescue Exception => exception

        # string for exception message
        dump_location = ""

        # check if xml parse error logging is enabled
        if MobyUtil::KernelHelper.to_boolean( MobyUtil::Parameter[ :logging_xml_parse_error_dump, 'true' ] )

          # generate filename for xml dump
          filename = MobyUtil::KernelHelper.to_boolean( MobyUtil::Parameter[ :logging_xml_parse_error_dump_overwrite, 'false' ] ) ? 'xml_error_dump.xml' : 'xml_error_dump_%i.xml' % Time.now

          # ... join filename with xml dump output path 
          path = File.join( MobyUtil::FileHelper.expand_path( MobyUtil::Parameter[ :logging_xml_parse_error_dump_path, 'logfiles/' ] ), filename )

			    # create error dump folder if not exist, used e.g. when xml parse error
			    MobyUtil::FileHelper.mkdir_path( File.dirname( path ) )

          # write xml string to file
          File.open( path, "w" ){ | file | file << xml_string }

          dump_location = ". Saved to %s" % path

        end

        # raise exception
				Kernel::raise MobyUtil::XML::ParseError.new( "%s (%s)%s" % [ exception.message.gsub("\n", ''), exception.class, dump_location ] )

			end

		end

		# Create XML Document object by parsing XML from file
		#
		# Usage: MobyUtil::XML.parse_file('xml_dump.xml') 
		#  ==> Returns XML document object; default xml parser will be used. 
		#
		# == params
		# filename:: String containing path and filename of XML file.
		# parser:: XML parser class e.g. MobyUtil::XML::Nokogiri
		# == return
		# Document:: XML document object
		# == raises
		# IOError:: File '%s' not found    
		def self.parse_file( filename )    

			# raise exception if file not found
			Kernel::raise IOError.new( "File '%s' not found" % filename ) unless File.exist?( filename )

			self.parse_string( IO.read( filename ), current_parser )

		end

		# Create XML builder object dynamically
		#
		# Usage:
		#
		#	MobyUtil::XML.build{
		#		root{
		#			element(:name => "element_name", :id => "0") {
		#				child(:name => "1st_child_of_element_0", :value => "123" )				
		#				child(:name => "2nd_child_of_element_0", :value => "456" )
		#			}
		#		}
		#	}.to_xml
		#
		# == params
		# &block:: 
		# == return
		# MobyUtil::XML::Builder
		# == raises
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
