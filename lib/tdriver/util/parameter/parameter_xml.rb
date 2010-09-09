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

  class ParameterXml

    include Singleton

    @@initialized = false

    # initialize class with default values
    def initialize

      reset

      @@initialized = true

    end

    def reset

      @@sut_list = []

    end

    # return list of configured suts
    def sut_list

      @@sut_list

    end

    # Recursive function to process xml. Requires input to be either a valid xml fragment (as string) or a xml fragment as object. 
    # Note: validity of the xml-fragment is not checked: please use appropriate methods for that
    # === params
    # root_element:: document or string containing xml
    # === returns
    # Hash:: Hash containing any attributes, parameters and id:s
    # === raises
    # SyntaxError:: if parameter-element does not have a name
    # ParameterError:: if loading subfile fails, see get_xmldocument_from_file function
    def parse( xml )

      # default results 
      results = ParameterHash.new()

      begin
        # create new xml document
        document = MobyUtil::XML::parse_string( xml )

      rescue Exception => exception

        Kernel::raise ParameterFileParseError.new( "Error occured while parsing XML. Reason %s (%s)" % [ exception.message, exception.class ] )

      end

      # go through each element in xml
      document.xpath( "/#{ document.root.name }/*" ).each{ | element |

        attribute = element.attributes.to_hash

        name = attribute[ "name" ].to_s
        value = attribute[ "value" ].to_s

        case element.name
            
          when 'fixture'

            plugin = attribute[ "plugin" ].to_s

            Kernel::raise SyntaxError.new( "No name defined for fixture with value %s" % name ) if name.empty?
            Kernel::raise SyntaxError.new( "No plugin defined for fixture with name %s" % name ) if plugin.empty?

            value = plugin

          when 'parameter'

            Kernel::raise SyntaxError.new( 

              "No name defined for parameter with value %s" % attribute[ 'value' ]

            ) unless attribute[ "name" ]

        else

          if element.name == 'sut'

            id = attribute[ 'id' ].to_s

            # store sut id to array if element is type of sut
            @@sut_list << id unless @@sut_list.include?( id ) 

          end

          # get template name(s) if given
          templates = attribute[ "template" ].to_s

          # empty value by default - content will be retrieved above
          value = ParameterHash.new()

          # use template if defined
          value = MobyUtil::ParameterTemplates.instance.get_template_from_xml( templates.to_s ) unless templates.empty?

          # read xml file from given location if defined - otherwise pass content as is
          if element.attribute( "xml_file" )

            content = parse( MobyUtil::FileHelper.get_file( element.attribute( "xml_file" ).to_s ) )

          else

            content = parse( "<xml>#{ element.inner_xml }</xml>" )

          end

          value.merge_with_hash!( content )

          name = ( element.attribute( "id" ) || element.name ).to_s

        end

        # store values to parameters
        results[ name.to_sym ] = value

      }

      # dispose xml document
      document = nil

      # return results hash
      results

    end

    def load_file( filename )

      filename = MobyUtil::FileHelper.expand_path( filename )

      begin

        file_content = MobyUtil::FileHelper.get_file( filename )

      rescue EmptyFilenameError

        Kernel::raise EmptyFilenameError.new( "Unable to load parameters xml file due to filename is empty or nil" )

      rescue FileNotFoundError => exception

        Kernel::raise exception

      rescue IOError => exception

        Kernel::raise IOError.new( "Error occured while loading xml file. Reason: %s (%s)"  % [ exception.message, exception.class ] )

      rescue => exception

        Kernel::raise ParameterFileParseError.new("Error occured while parsing parameters xml file %s\nDescription: %s" % [ filename, exception.message ] )

      end

    end

    def parse_file( filename )

      begin
      
        parse( 

          load_file( filename ) 

        )

      rescue Exception => exception

        Kernel::raise ParameterFileParseError.new( 

          "Error occured while parsing parameters xml file %s. Reason: %s (%s)" % [ filename, exception.message, exception.class ] 

        )

      end

    end

    def merge_files( path, root_element_name, xpath_to_element = '/*', &block )

      @filename = ""

      xml = ""

      begin
  
        # merge all xml files
        Dir.glob( File.join( MobyUtil::FileHelper.expand_path( path ), '/*.xml' ) ).each { | filename | 

          @file_name = filename

          content = MobyUtil::FileHelper.get_file( filename )

          xml << MobyUtil::XML::parse_string( content ).root.xpath( xpath_to_element ).to_s

          # pass the filename to block if one given
          yield( filename ) if block_given?

        }

        xml = "<%s>%s</%s>" % [ root_element_name, xml.to_s, root_element_name ]

      rescue MobyUtil::EmptyFilenameError

        Kernel::raise EmptyFilenameError.new( "Unable to load xml file due to filename is empty or nil" )

      rescue MobyUtil::FileNotFoundError => exception

        Kernel::raise exception

      rescue Exception => exception

        Kernel::raise RuntimeError.new( "Error occured while parsing xml file %s. Reason: %s (%s)" % [ @filename, exception.message, exception.class ] )

      end

      xml

    end

    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # ParameterXml

end # MobyUtil
