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

      hash.check_type( [ Hash, ParameterHash ], "Wrong argument type $1 for hash (expected $2)" )

      merge!( 

        convert_hash( hash )

      )

    end

    def convert_hash( value )

      if value.kind_of?( ParameterHash )
      
        value
        
      elsif value.kind_of?( Hash )
      
        ParameterHash[
        
          value.collect{ | key, value |
          
            [ key, convert_hash( value ) ]
            
          }

        ]

      else
      
        # return as is if not kind of hash/parameter hash
        value
      
      end

    end

    def []( key, *default, &block )

      $last_parameter = fetch( key ){ 

        if default.empty?

          raise ParameterNotFoundError, "Parameter #{ key } not found." unless block_given?

          # yield with key if block given
          yield( key )

        else
        
          raise ArgumentError, "Only one default value allowed for parameter (#{ default.join(", ") })" unless default.size == 1

          convert_hash( default.first )

        end

      }

    end

    def []=( key, value )

      raise ParameterNotFoundError, "Parameter key nil is not valid." unless key

      store key, convert_hash( value )

    end

    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterHash

  class Parameter
  
    # private methods
    class << self
    
      private

      def initialize_class
      
        # default values
        @@parameters = MobyUtil::ParameterHash.new

        @@templates = MobyUtil::ParameterHash.new

        @@platform = nil
        
        @@is_posix = nil
        
        @@sut_list = []

      end

      def load_default_parameters
      
        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'defaults/*.xml' ) ).each { | filename | 

          content = MobyUtil::FileHelper.get_file( filename )

          MobyUtil::XML::parse_string( content ).xpath( '*' ).each{ | element |

            @@parameters.recursive_merge!( 
            
              parse_element( element )
              
            )
            
          }

        }
      
      end

      # load additional parameter xml files
      def load_parameters_xml( filename, reset = false )

        @@parameters = MobyUtil::ParameterHash.new if reset == true

        filename = MobyUtil::FileHelper.expand_path( filename )

        raise MobyUtil::FileNotFoundError, "Parameters file #{ filename } does not exist" unless File.exist?( filename )

        @@parameters.recursive_merge!(

          parse_file( filename )

        )

        #@@loaded_parameter_files << filename

      end

      # TODO: document me
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

      # TODO: document me
      def parse_file( filename )

        begin
        
          parse_element(

            MobyUtil::XML.parse_string( 
            
              load_file( filename )
              
            ).root

          )

        rescue Exception

          raise ParameterFileParseError, "Error occured while parsing parameters xml file #{ filename }. Reason: #{ $!.message } (#{ $!.class })"

        end

      end
      
      
      
      def parse_element( xml )
    
        # default results 
        results = MobyUtil::ParameterHash.new

        # go through each element in xml
        xml.xpath( "*" ).each{ | element |

          attribute = element.attributes.to_hash

          # default value
          value = attribute[ "value" ].to_s

          # generic posix value - overwrites attribute["value"] if found
          value = attribute[ "posix" ].to_s unless attribute[ "posix" ].nil? if @@is_posix

          # platform specific value - overwrites existing value
          value = attribute[ @@platform.to_s ].to_s unless attribute[ @@platform.to_s ].nil?

          case element.name
              
            when 'fixture'

              name = attribute[ "name" ].to_s

              plugin = attribute[ "plugin" ].to_s

      		    env = attribute[ "env" ].to_s unless attribute[ "env" ].nil?

              raise SyntaxError, "No name defined for fixture with value #{ name }" if name.empty?

              raise SyntaxError, "No plugin defined for fixture with name #{ name }" if plugin.empty?

     		      value = { :plugin => plugin, :env => env }

            when 'parameter'

              name = attribute[ "name" ].to_s

              raise SyntaxError, "No name defined for parameter with value #{ value }" if name.empty?

            when 'sut'

              name = attribute[ 'id' ].to_s
            
              @@sut_list << name unless @@sut_list.include?( name ) 
   
              templates = attribute[ "template" ].to_s         

              # empty value by default
              value = ParameterHash.new

              unless templates.empty?

                templates.split(";").each{ | template |
                
                  value.recursive_merge!( 
                  
                    get_template( templates )
                  
                  )
                
                }

              end

              value.recursive_merge!( parse_element( element ) )

          else

            value = ParameterHash.new

            xml_file = element.attribute( "xml_file" )

            # read xml file from given location if defined - otherwise pass content as is
            if element.attribute( "xml_file" )

              content = parse_element( 
              
                MobyUtil::XML.parse_string(
                  
                  MobyUtil::FileHelper.get_file( xml_file.to_s )
                  
                )
                
              )

            else

              content = parse_element( element )

            end

            # merge hash values (value type of hash)
            value.recursive_merge!( content )
            
            name = element.name

          end

          # store values to parameters
          results[ name.to_sym ] = value

        }

        # return results hash
        results

      end
      
      def parse_template( name )
      
        template = @@templates_hash[ name ]
        
        unless template.kind_of?( Hash )
        
          result = MobyUtil::ParameterHash.new
              
          template[ 'inherits' ].to_s.split(";").each{ | inherited_template |
                
            result.recursive_merge!( 
            
              parse_template( inherited_template )
            
            )
          
          }
          
          @@templates_hash[ name ] = result.recursive_merge!( 
          
            parse_element( template ) 
          
          )
        
        else

          template

        end
      
      end    

      def load_template_files( reset = true )

        @@templates_hash = MobyUtil::ParameterHash.new if reset

        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'templates/*.xml' ) ).each { | filename | 

          content = MobyUtil::FileHelper.get_file( filename )

          MobyUtil::XML::parse_string( content ).root.xpath( 'template' ).each{ | template |

            # store template element to hash
            @@templates_hash[ template[ 'name' ] ] = template
            
          }

        }
        
        # parse templates hash; convert elements to hash
        @@templates_hash.each_pair{ | name, template | 
        
          parse_template( name )
        
        }
      
      end

      def get_template( name )
      
        @@templates_hash.fetch( name )
      
      end

    end # self

    def self.init

      # retrieve platform name
      @@platform = MobyUtil::EnvironmentHelper.platform

      # detect is posix platform
      @@is_posix = MobyUtil::EnvironmentHelper.posix?

      # load parameter templates
      load_template_files

      # apply global parameters to root level (e.g. MobyUtil::Parameter[ :logging_outputter_enabled ])
      @@parameters.recursive_merge!( get_template( 'global' ) )

      load_default_parameters

      load_parameters_xml( 'tdriver_parameters.xml' )
  
    end

    def self.keys
    
      @@parameters.keys
    
    end

    def self.[]( key, *default )
    
      @@parameters[ key, *default ]
          
    end

    def self.[]=( key, value )
    
      @@parameters[ key ] = value
    
    end
    
    def self.inspect
    
      @@parameters.inspect
    
    end

    def self.fetch( key, *default, &block )

      @@parameters.__send__( :[], key, *default, &block )

    end

    def self.templates
    
      @@templates_hash
    
    end
    
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    # initialize parameters class
    initialize_class

  end # Parameter
  
end # MobyUtil

# set global variable pointing to parameter class
$parameters = MobyUtil::Parameter

# set global variable pointing to parameter API class
$parameters_api = MobyUtil::ParameterUserAPI

# initialize parameters
$parameters.init

