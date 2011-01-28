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

=begin
    # TODO: document me
    def initialize #( hash = {} )

      hash.check_type( [ Hash, ParameterHash ], "Wrong argument type $1 for hash (expected $2)" )

      merge!( 

        convert_hash( hash )

      ) unless hash.empty?

    end
=end

    # TODO: document me
    def convert_hash( value )

=begin
      if value.kind_of?( Hash )
        
        # convert hash to parameter hash                
        ParameterHash[
        
          value.collect{ | key, value |
          
            [ key, value.kind_of?( Hash ) ? convert_hash( value ) : value ]
            
          }

        ]
        
      else

        # return as is
        value
        
      end
=end

      value.kind_of?( Hash ) ? ParameterHash[ value.collect{ | key, value | [ key, value.kind_of?( Hash ) ? convert_hash( value ) : value ] } ] : value

    end

    # TODO: document me
    def []( key, *default, &block )

      $last_parameter = fetch( key ){ 

        if default.empty?

          raise ParameterNotFoundError, "Parameter #{ key } not found." unless block_given?

          # yield with key if block given
          yield( key )

        else
        
          raise ArgumentError, "Only one default value allowed for parameter (#{ default.join(", ") })" unless default.size == 1
          
          # convert_hash( default.first )

          result = default.first
          
          result.kind_of?( Hash ) ? convert_hash( result ) : result
          
        end

      }

    end

    # TODO: document me
    def []=( key, value )

      raise ParameterNotFoundError, "Parameter key nil is not valid." unless key

      super key, value.kind_of?( Hash ) ? convert_hash( value ) : value

    end

    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterHash

  class Parameter
  
    # private methods
    class << self
    
      private

      # TODO: document me
      def initialize_class
      
        # default values
        @@parameters = MobyUtil::ParameterHash.new

        @@templates_hash = MobyUtil::ParameterHash.new

        @@platform = nil
        
        @@is_posix = nil
        
        @@sut_list = []

        @@cache = {}

      end

      # TODO: document me
      def load_default_parameters
      
        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'defaults/*.xml' ) ).each { | filename | 

          MobyUtil::XML::parse_string( load_file( filename ) ).xpath( '*' ).each{ | element |

            @@parameters.recursive_merge!( 
            
              parse_element( element )
              
            )
            
          }

        }
      
      end

      # load additional parameter xml files
      def load_parameters_xml( filename, reset = false )

        @@parameters = MobyUtil::ParameterHash.new if reset == true

        begin

        @@parameters.recursive_merge!(

          parse_file( filename )

        )
        
        rescue MobyUtil::FileNotFoundError

          raise $!, "Parameters file #{ MobyUtil::FileHelper.expand_path( filename ) } does not exist"
        
        end

        #@@loaded_parameter_files << filename

      end

      # TODO: document me
      def load_file( filename )

        filename = MobyUtil::FileHelper.expand_path( filename )

        begin

          MobyUtil::FileHelper.get_file( filename )

        rescue MobyUtil::EmptyFilenameError

          raise $!, "Unable to load parameters xml file due to filename is empty or nil"

        rescue MobyUtil::FileNotFoundError

          raise $!

        rescue IOError

          raise $!, "Error occured while loading xml file. Reason: #{ $!.message }"

        rescue

          raise MobyUtil::ParameterFileParseError, "Error occured while parsing parameters xml file #{ filename }\nDescription: #{ $!.message }"

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

        rescue

          raise MobyUtil::ParameterFileParseError, "Error occured while parsing parameters xml file #{ filename }. Reason: #{ $!.message } (#{ $!.class })"

        end

      end
            
      # TODO: document me
      def parse_element( xml )
                
        # calculate xml hash
        xml_hash = xml.to_s.hash
                
        return @@cache[ xml_hash ] if @@cache.has_key?( xml_hash )

        # default results 
        results = MobyUtil::ParameterHash.new

        # go through each element in xml
        xml.xpath( "*" ).each{ | element |

          # retrieve element attributes as hash
          attributes = element.attributes

          # default value
          value = attributes[ "value" ]

          # generic posix value - overwrites attribute["value"] if found
          value = attributes[ "posix" ] unless attributes[ "posix" ].nil? if @@is_posix

          # platform specific value - overwrites existing value
          value = attributes[ @@platform.to_s ] unless attributes[ @@platform.to_s ].nil?

          # retrieve name attribute
          name = attributes[ "name" ]

          case element.name
              
            when 'fixture'

              name.not_blank( "No name defined for fixture \"#{ element.to_s }\"", SyntaxError )

     		      value = { 
     		      
     		        :plugin => attributes[ "plugin" ].not_blank( "No name defined for fixture with value #{ name }", SyntaxError ),
     		         
     		        :env => attributes[ "env" ]
     		        
   		        }
   		        
            when 'parameter'

              # verify that name attribute is defined
              name.not_blank( "No name defined for parameter with value #{ value }", SyntaxError )

              # return value as is
              #value.not_nil( "No value defined for parameter with name #{ name }", SyntaxError )

              value = "" if value.nil?

            when 'sut'

              # use id as parameter name
              name = attributes[ 'id' ]

              # verify that name attribute is defined
              name.not_blank( "No name defined for SUT \"#{ element.to_s }\"", SyntaxError )
            
              # add SUT to found sut list
              @@sut_list << name unless @@sut_list.include?( name ) 
   
              # retrieve names of used templates 
              templates = attributes[ "template" ]

              # empty value by default
              value = ParameterHash.new

              unless templates.blank?

                # retrieve each defined template
                templates.split(";").each{ | template |
                
                  # merge template with current value hash
                  value.recursive_merge!( 
        
                    # retrieve template          
                    get_template( template )
                  
                  )
                
                }

              end

              # merge sut content with template values
              value.recursive_merge!( parse_element( element ) )

          else

            # use element name as parameter name (e.g. fixture, keymap etc)
            name = element.name

            # read xml file from given location if defined - otherwise pass content as is
            if attributes[ "xml_file" ]

              # merge hash values (value type of hash)
              value = parse_file( attributes[ "xml_file" ] )

            else

              # use element content as value
              value = parse_element( element )

            end
            
          end

          # store values to parameters
          results[ name.to_sym ] = value

        }

        # store to cache
        @@cache[ xml_hash ] = results

        # return results hash
        results

      end
      
      def parse_template( name )
      
        template = @@templates_hash[ name ]
        
        unless template.kind_of?( Hash )
        
          result = ParameterHash.new
          
          # retrieve each inherited template
          template[ 'inherits' ].to_s.split(";").each{ | inherited_template |
                
            result.recursive_merge!( 
            
              parse_template( inherited_template )
            
            )
          
          }
          
          # merge template content with inherited templates and store to templates hash table 
          @@templates_hash[ name ] = result.recursive_merge!( 
          
            parse_element( template ) 
          
          )
   
        else
        
          # template is already parsed, pass template hash as is 
          template
                
        end
      
      end

      def load_template_files

        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'templates/*.xml' ) ).each { | filename | 

          MobyUtil::XML::parse_string( load_file( filename ) ).root.xpath( 'template' ).each{ | template |

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
