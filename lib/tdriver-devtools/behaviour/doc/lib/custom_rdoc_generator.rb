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

module Generators

  abort("") unless defined?( RDoc )

	class TDriverFeatureTestGenerator

    def self.for( options )

      new( options )

    end

    def load_templates

      Dir.glob( File.join( File.dirname( File.expand_path( __FILE__ ) ), '..', 'templates', '*.template' ) ).each{ | file |

        name = File.basename( file ).gsub( '.template', '' )

        @templates[ name ] = open( file, 'r' ).read

      }

    end

    def initialize( options )

      @templates = {}

      load_templates

      @options = options

      @already_processed_files = []

      @current_module_tests = []

      @current_module = nil

      @output = { :files => [], :classes => [], :modules => [], :attributes => [], :methods => [], :aliases => [], :constants => [], :requires => [], :includes => []}

    end

    def generate( files )

      # process files
      files.each{ | file |
        
        process_file( file ) unless @already_processed_files.include?( file.file_absolute_name )

      }

    end

    def process_file( file )

      @module_path = []
      
      @current_file = file
  
      process_modules( file.modules )    

    end

    def process_modules( modules )

      modules.each{ | _module | 

        unless @already_processed_files.include?( _module.full_name )

          @module_path.push( _module.name )

          process_module( _module ) 

          @module_path.pop

        end

      }

    end

    def process_methods( methods )

      results = []

      methods.each{ | method | 

        results << process_method( method ) 

      }

      Hash[ results ]

    end

    def process_method_arguments_section( source )

      result = []

      current_argument = nil

      current_argument_type = nil

      current_section = nil

      argument_index = -1

      source.lines.to_a.each_with_index{ | line, index | 
        
        # remove cr/lf
        line.chomp!

        # remove trailing whitespaces
        line.rstrip!

        # count nesting depth
        line.match( /^(\s*)/ )

        nesting = $1.size

        # remove leading whitespaces
        line.lstrip!

        if nesting == 0

          line =~ /^(\w+)$/i

          unless $1.nil?

            # argument name
            current_argument = $1 

            current_section = nil

            current_argument_type = nil

            result << { current_argument => {} }

            argument_index += 1

          end

        else

          # is line content class name? (argument variable type)
          line =~ /^(\w+)$/i

          if !$1.nil? && ( 65..90 ).include?( $1[0] ) # "Array", "String", "Integer"

            #Kernel.const_get( $1 ) rescue abort( "Line %s: \"%s\" is not valid argument variable type. (e.g. OK: \"String\", \"Array\", \"Fixnum\" etc) " % [ index +1, $1 ] )

            current_argument_type = $1

            result[ argument_index ][ current_argument ][ current_argument_type ] = {}

            current_section = nil

          else

            abort("Unable add argument details (line %s: \"%s\") for \"%s\" due to argument variable type must be defined first.\nPlease note that argument type must start with capital letter (e.g. OK: \"String\" NOK: \"string\")" % [ index + 1, line, current_argument  ] ) if current_argument_type.nil?

            line =~ /^(.*?)\:{1}($|[\r\n\t\s]{1})(.*)$/i

            if $1.nil?

              abort("Unable add argument details (line %s: \"%s\") for \"%s\" due to section name not defined. Sections names are written in lowercase with trailing colon and whitespace (e.g. OK: \"example: 10\", NOK: \"example:10\")" % [ index +1, line, current_argument]) if $1.nil? && current_section.nil?

              # remove leading & trailing whitespaces
              section_content = line.strip

            else

              current_section = $1

              unless result[ argument_index ][ current_argument ][ current_argument_type ].has_key?( current_section )

                result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ] = ""

              end
          
              section_content = $3.strip

            end

            abort("Unable add argument details due to argument not defined. Argument name must start from pos 1 of comment. (e.g. \"# my_variable\" NOK: \"#  my_variable\", \"#myvariable\")") if current_argument.nil?  

            # add one leading whitespace if current_section value is not empty 
            section_content = " " + section_content unless result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ].empty?

            # store section_content to current_section
            result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ] << section_content

            #puts "%s#%s#%s: %s" % [ current_argument, current_argument_type, current_section, section_content ]

          end

        end

      }

      result

    end

    def process_formatted_section( source )

      result = []

      current_argument_type = nil

      current_section = nil

      argument_index = -1

      source.lines.to_a.each_with_index{ | line, index | 
        
        # remove cr/lf
        line.chomp!

        # remove trailing whitespaces
        line.rstrip!

        # count nesting depth
        line.match( /^(\s*)/ )

        nesting = $1.size

        # remove leading whitespaces
        line.lstrip!

        if nesting == 0

          line =~ /^(\w+)/i

          if !$1.nil? && (65..90).include?( $1[0] )

            #Kernel.const_get( $1 ) rescue abort( "Line %s: \"%s\" is not valid argument variable type. (e.g. OK: \"String\", \"Array\", \"Fixnum\" etc) " % [ index + 1, $1 ] ) if verify_type

            # argument type
            current_argument_type = $1

            current_section = nil

            result << { current_argument_type => {} }

            argument_index += 1

          end

         else

            abort("Unable add value details (line %s: \"%s\") for %s due to detail type must be defined first.\nPlease note that return value type must start with capital letter (e.g. OK: \"String\" NOK: \"string\")" % [ index + 1, line, current_argument  ] ) if current_argument_type.nil?

            line =~ /^(.*?)\:{1}($|[\r\n\t\s]{1})(.*)$/i

            if $1.nil?

              abort("Unable add value details (line %s: \"%s\") for %s due to section name not defined. Sections names are written in lowercase with trailing colon and whitespace (e.g. OK: \"example: 10\", NOK: \"example:10\")" % [ index +1, line, current_argument]) if $1.nil? && current_section.nil?

              # remove leading & trailing whitespaces
              section_content = line.strip

            else

              current_section = $1
              
              unless result[ argument_index ][ current_argument_type ].has_key?( current_section )

                result[ argument_index ][ current_argument_type ][ current_section ] = ""

              end
          
              section_content = $3.strip

            end

            abort("Unable add return value details due to variable type not defined. Argument type must be defined at pos 1 of comment. (e.g. \"# Integer\" NOK: \"#  Integer\", \"#Integer\")") if current_argument_type.nil?  

            # add one leading whitespace if current_section value is not empty 
            section_content = " " + section_content unless result[ argument_index ][ current_argument_type ][ current_section ].empty?

            # store section_content to current_section
            result[ argument_index ][ current_argument_type ][ current_section ] << section_content

            #puts "%s#%s: %s" % [ current_argument_type, current_section, section_content ]

        end


      }

      result

    end


    def process_method( method )

      results = []

      method_header = nil

      if ( method.visibility == :public && @module_path.first =~ /MobyBehaviour/ )

        @current_method = method

        method_header = process_comment( method.comment )

        ## TODO: remember to verify that there are documentation for each argument!
        ## TODO: verify that there is a tag for visualizer example

        method_header = Hash[ method_header.collect{ | key, value |

          if key == :arguments

            value = process_method_arguments_section( value )

          end

          if key == :returns

            value = process_formatted_section( value )

          end

          if key == :exceptions

            value = process_formatted_section( value )

          end


          [ key, value ]

        }]


        # do something
        [ method.name, method_header ]

      else

        nil
    
      end

    end

    # verify if 
    def has_method?( target, method_name )

        target.method_list.select{ | method | 
        
          method.name == method_name 
          
        }.count > 0
    
    end

    def process_attributes( attributes )

      results = []

      attributes.each{ | attribute | 

        p attibute.comment

        # TODO: tapa miten saadaan attribuuttien getteri ja setteri dokumentoitua implemenaatioon

      }

      results

    end

    def process_comment( comment )

      header = {}

      current_section = nil

      comment.each_line{ | line |

        # remove '#' char from beginning of line
        line.slice!( 0 )

        # if next character is whitespace assume that this is valid comment line
        # NOTE: that if linefeed is required use "#<#32><#10>"
        if [ 32 ].include?( line[ 0 ] )

          # remove first character
          line.slice!( 0 )

          # if line is a section header
          if line[ 0..2 ] == "== "

            # remove section header indicator string ("== ")
            line.slice!( 0..2 )

            # remove cr/lf
            line.gsub!( /[\n\r]/, "" )

            current_section = line.to_sym

          else

            unless current_section.nil?

              # remove cr/lf 
              # NOTE: if crlf is required use '\n'
              line.gsub!( /[\n\r]/, "" )

              # store to header hash
              if header.has_key?( current_section )

                header[ current_section ] << "\n" << ( line.rstrip )

              else

                header[ current_section ] = line.rstrip

              end

            else

              #puts "[nodoc?] %s" % line

            end

          end

        else

          #puts "[nodoc] %s" % line

        end

      }

      header

      #p _module.methods.sort

    end

    def apply_macros!( source, macros )
        
      macros.each_pair{ | key, value |
                  
        source.gsub!( /(\$#{ key })\b/, value || "" )
      
      }
      
      source
    
    end

    def xx( header, *features )

      # collect method and attribute templates
      methods = features.collect{ | feature_set |
      
        feature_set.collect{ | feature |
                  
          exceptions = ""

          # TODO: tarkista lähdekoodista että onko argument optional vai ei
          # TODO: tarkista että onko kaikki argumentit dokumentoitu
          
          # generate arguments xml
          arguments = ( feature.last[:arguments] || {} ).collect{ | arg |
                        
            
            # generate argument types template
            arg.collect{ | argument |

             default_value_set = false 
             default_value = nil
                        
             types_xml = argument.last.collect{ | type |

               unless type.last["default"].nil?

                 # show warning if default value for optional argument is already set
                 warn( "Error: Default value for optional argument '%s' (%s) is already set! ('%s' --> '%s')" % [ argument.first, @module_path.join("::"), default_value, type.last["default"] ] ) if default_value_set == true

                 default_value = type.last["default"]
                 default_value_set = true

               end

               apply_macros!( @templates["behaviour.xml.argument_type"].clone, {
                
                  "ARGUMENT_TYPE" => type.first,
                  "ARGUMENT_DESCRIPTION" => type.last["description"],
                  "ARGUMENT_EXAMPLE" => type.last["example"],
               
                }
               )
             
             }.join
             
             # apply types to arguments template
             apply_macros!( @templates["behaviour.xml.argument"].clone, {
                "ARGUMENT_NAME" => argument.first,
                "ARGUMENT_TYPES" => types_xml,
                "ARGUMENT_DEFAULT_VALUE" => default_value || "",
                "ARGUMENT_OPTIONAL" => default_value_set.to_s
              }
             )
            
            }.join
          
          }.join
                               
          # generate return value types template
          returns = feature.last[ :returns ].collect{ | return_types |
          
            return_types.collect{ | returns |
            
               # apply types to arguments template
               apply_macros!( @templates["behaviour.xml.returns"].clone, {
                  "RETURN_VALUE_TYPE" => returns.first,
                  "RETURN_VALUE_DESCRIPTION" => returns.last["description"],
                  "RETURN_VALUE_EXAMPLE" => returns.last["example"],
                }
               )
              
            }.join
         
          }.join
          
          # generate exceptions template
          exceptions = feature.last[ :exceptions ].collect{ | exceptions |
          
            exceptions.collect{ | exception |
            
               # apply types to arguments template
               apply_macros!( @templates["behaviour.xml.exception"].clone, {
                  "EXCEPTION_NAME" => exception.first,
                  "EXCEPTION_DESCRIPTION" => exception.last["description"]
                }
               )
              
            }.join
         
          }.join
                                        
          # generate method template            
          apply_macros!( @templates["behaviour.xml.method"].clone, { 
            "METHOD_NAME" => feature.first,
            "METHOD_DESCRIPTION" => feature.last[:description],
            "METHOD_ARGUMENTS" => arguments,
            "METHOD_RETURNS" => returns,
            "METHOD_EXCEPTIONS" => exceptions,
            "METHOD_INFO" => feature.last[:info]
           } 
          )
        
        }.join
      
      }.join

      # apply header
      puts apply_macros!( @templates["behaviour.xml"].clone, { 
        "REQUIRED_PLUGIN" => header[:requires],
        "BEHAVIOUR_NAME" => header[:behaviour],
        "BEHAVIOUR_METHODS" => methods,
        "OBJECT_TYPE" => header[:objects],
        "SUT_TYPE" => header[:sut_type],
        "INPUT_TYPE" => header[:input_type],
        "VERSION" => header[:sut_version],
        "MODULE_NAME" => @module_path.join("::")
        } 
      )    
    
    end

    def process_module( _module )

      @already_processed_files << _module.full_name

      module_header = process_comment( _module.comment )

      unless module_header.empty?

        # process methods
        methods = process_methods( _module.method_list )

        # process attributes
        attributes = process_attributes( _module.attributes )

        xx( module_header, methods, attributes )

      end

      # process if any child modules 
      process_modules( _module.modules ) unless _module.modules.empty?

    end

  end

end
