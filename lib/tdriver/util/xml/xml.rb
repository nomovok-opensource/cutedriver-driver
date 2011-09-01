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

    class << self
    
    private
    
      def initialize_class
      
        # empty xml cache hash
        @document_cache = { :cache => [], :objects => {} }

        # default xml cache buffer size
        @document_cache_buffer_size = 10

        # set used parser module
        self.current_parser = MobyUtil::XML::Nokogiri        
      
      end
    
    end

    # Get current XML parser
    # == params
    # == return
    # Module:: 
    # == raises
    def self.current_parser

      @@parser

    end

    # Set XML document cache buffering size, set 0 to disable
    # == params
    # == return
    # Integer:: 
    # == raises
    # TypeError::
    def self.buffer_size=( value )
    
      value.check_type Integer, 'wrong argument type $1 for XML cache buffer size (expected $2)' 
    
      @document_cache_buffer_size = value
    
    end

    # Get current XML document cache buffering size
    # == params
    # == return
    # Integer:: 
    # == raises
    def self.buffer_size
      
      @document_cache_buffer_size
    
    end

    # Set XML parser to be used
    # == params
    # Module:: 
    # == return
    # nil
    # Document:: XML document object
    # == raises
    def self.current_parser=( value )

      #raise RuntimeError, "Parser can be set only once per session" unless defined?( @@parser )

      # set current parser
      @@parser = value

      # apply parser implementation to abstraction modules
      [ 
        :Document, 
        :Element, 
        :Nodeset, 
        :Attribute, 
        :Text, 
        :Builder,
        :Comment 
        
      ].each do | _module |

        const_get( _module ).module_exec{

          begin      

            # include parser behaviour
            include @@parser.const_get( _module ) 

          rescue NameError

            # raise proper exception if behaviour module not found
            raise NotImplementedError, "Required behaviour module #{ @@parser.name }::#{ _module } not found"
            
          end
        
        }
        
      end

      # return current parser as result
      value

    end

    # Create XML Document object by parsing XML from string
    #
    # Usage: MobyUtil::XML.parse_string('<root>value</root>') 
    #  ==> Returns XML document object; default xml parser will be used. 
    #
    # == params
    # xml_string:: String containing XML  
    # crc:: Optional CRC16 checksum - used for cache/buffering if given
    # == return
    # Document:: XML document object
    # Array:: Array containing XML document object and status was it already found from cache
    # == raises
    def self.parse_string( xml_string, crc = nil )

      begin

=begin
        unless crc.nil?

          [ Document.new( xml_string ), false ]

        else

          Document.new( xml_string )
        
        end
=end

# JKo: disable xml caching for now, need more investigation why tests starts to fail
#=begin
        unless crc.nil?

          if @document_cache[ :cache ].include?( crc )

            # return cached object and status that object was found from cache
            [ @document_cache[ :objects ][ crc ], true ]

          else
  
            cache_enabled = ( @document_cache_buffer_size > 0 )

            # create new document object with given xml string
            document = Document.new( xml_string, { :cache_enabled => cache_enabled } )

            # verify that xml caching is enabled
            if cache_enabled

              # drop olders cached xml object
              if @document_cache[ :cache ].count == @document_cache_buffer_size

                # remove data object from cache
                @document_cache[ :objects ].delete( 

                  # take (oldest) first from cache buffer
                  @document_cache[ :cache ].shift

                )

              end

              # add new xml data object to cache
              @document_cache[ :cache ] << crc

              # add new xml data object to cache
              @document_cache[ :objects ][ crc ] = document 

            end

            # return document object and status that object was not found from cache
            [ document, false ]
            
          end

        else

          # create new document object with given xml string - no caching used
          Document.new( xml_string )

        end
#=end
      rescue

        if $TDRIVER_INITIALIZED == true
        
          # string for exception message
          dump_location = ""

          # check if xml parse error logging is enabled
          if $parameters[ :logging_xml_parse_error_dump, 'true' ].to_s.to_boolean

            # construct filename for xml dump
            filename = 'xml_error_dump'

            # add timestamp to filename if not overwriting the existing dump file 
            unless $parameters[ :logging_xml_parse_error_dump_overwrite, 'false' ].to_s.to_boolean

              filename << "_#{ Time.now.to_i }"

            end

            # add file extension
            filename << '.xml'

            # ... join filename with xml dump output path 
            path = File.join( MobyUtil::FileHelper.expand_path( $parameters[ :logging_xml_parse_error_dump_path ] ), filename )

            begin

              # write xml string to file
              File.open( path, "w" ){ | file | file << xml_string }

              dump_location = "Saved to #{ path }"

            rescue

              dump_location = "Error while saving to file #{ path }"

            end

          end

          # raise exception
          raise MobyUtil::XML::ParseError, "#{ $!.message.gsub("\n", '') } (#{ $!.class }). #{ dump_location }"

        else
        
          # raise exception
          raise MobyUtil::XML::ParseError, "#{ $!.message.gsub("\n", '') } (#{ $!.class })"
        
        end

      end

    end

    # Create XML Document object by parsing XML from file
    #
    # Usage: MobyUtil::XML.parse_file('xml_dump.xml') 
    #  ==> Returns XML document object; default xml parser will be used. 
    #
    # == params
    # filename:: String containing path and filename of XML file.    
    # == return
    # Document:: XML document object
    # == raises
    # IOError:: File '%s' not found    
    def self.parse_file( filename )    
  
      # raise exception if file not found
      raise IOError, "File #{ filename.inspect } not found" unless File.exist?( filename )

      # parse file content
      parse_string( 
      
        IO.read( filename ) 
        
      )

    end

    # Create XML builder object dynamically
    #
    # Usage:
    #
    #  MobyUtil::XML.build{
    #    root{
    #      element(:name => "element_name", :id => "0") {
    #        child(:name => "1st_child_of_element_0", :value => "123" )        
    #        child(:name => "2nd_child_of_element_0", :value => "456" )
    #      }
    #    }
    #  }.to_xml
    #
    # == params
    # &block:: 
    # == return
    # MobyUtil::XML::Builder
    # == raises
    def self.build( &block )

      begin

        Builder.new.tap{ | builder | 

          builder.build( &block )

        }

      rescue

        raise MobyUtil::XML::BuilderError, "#{ $!.message } (#{ $!.class })"

      end
      
    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    # initialize class
    initialize_class

  end # XML

end # MobyUtil
