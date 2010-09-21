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

    def initialize( options )

      @templates = {}

      load_templates

      @options = options

      @already_processed_files = []

      @current_module_tests = []

      @current_module = nil

      @output = { :files => [], :classes => [], :modules => [], :attributes => [], :methods => [], :aliases => [], :constants => [], :requires => [], :includes => []}

      @errors = []

    end
   
    def help( topic )

      case topic

        when 'description'
<<-EXAMPLE
# == description
# This method returns "String" as return value
def my_method( arguments )
 return "string"
end
EXAMPLE

        when 'returns'
<<-EXAMPLE
# == returns
# String
#  description: example description
#  example: "string"
# 
def my_method( arguments )
 return "string"
end
EXAMPLE

        when 'arguments'
<<-EXAMPLE
# == arguments
# arg1
#  Integer
#   description: first argument can integer
#   example: 10
#  String
#   description: ... or string
#   example: "Hello"
#
# arg2
#  Array
#   description: MyArray
#   example: [1,2,3]
#   default: []
#
def my_method( arg1, arg2 )
  # ...
end
EXAMPLE

        when 'attr_argument'
<<-EXAMPLE
# == arguments
# value
#  Integer
#   description: first argument can integer
#   example: 10
attr_writer :my_attribute

or

# == arguments
# value
#  Integer
#   description: first argument can integer
#   example: 10
#  String
#   description: ... or string
#   example: "Hello"
attr_writer :my_attribute # ... when input value can be either Integer or String
EXAMPLE


        when 'exceptions'
<<-EXAMPLE
# == exceptions
# RuntimeError
#  description:  example exception #1
#
# ArgumentError
#  description:  example exception #2
def my_method

  # ...

end
EXAMPLE

        when 'behaviour_description'
<<-EXAMPLE
# == description
# This module contains demonstration implementation containing tags for documentation generation using gesture as an example
module MyBehaviour

  # ...

end
EXAMPLE

        when 'behaviour_name'
<<-EXAMPLE
# == behaviour
# MyPlatformSpecificBehaviour
module MyBehaviour

  # ...

end
EXAMPLE

        when 'behaviour_object_types'
<<-EXAMPLE
# == objects
# *
module MyBehaviour

  # apply behaviour to any test object, except SUT

end    

or

# == objects
# sut
module MyBehaviour

  # apply behaviour only to SUT object

end    

# == objects
# *;sut
module MyBehaviour

  # apply behaviour to any test object, including SUT

end    

or

# == objects
# MyObject
module MyBehaviour

  # apply behaviour only to objects which type is 'MyObject'

end    

or 

# == objects
# MyObject;OtherObject
module MyBehaviour

  # apply behaviour only to objects which type is 'MyObject' or 'OtherObject'
  # if more object types needed use ';' as separator.

end


EXAMPLE

        when 'behaviour_version'
<<-EXAMPLE
# == sut_version
# *
module MyBehaviour

  # any sut version 

end

or 

# == sut_version
# 1.0
module MyBehaviour

  # apply behaviour only to sut with version 1.0

end
EXAMPLE

        when 'behaviour_input_type'
<<-EXAMPLE
# == input_type
# *
module MyBehaviour

  # any input type 

end

or 

# == input_type
# touch
module MyBehaviour

  # apply behaviour only to sut which input type is 'touch'

end

or

# == input_type
# touch;key
module MyBehaviour

  # apply behaviour only to sut which input type is 'touch' or 'key'
  # if more types needed use ';' as separator.

end

EXAMPLE

        when 'behaviour_sut_type'
<<-EXAMPLE
# == sut_type
# *
module MyBehaviour

  # any input type 

end

or 

# == sut_type
# XX
module MyBehaviour

  # apply behaviour only to sut which sut type is 'XX'

end

or

# == sut_type
# XX;YY
module MyBehaviour

  # apply behaviour only to sut which sut type is 'XX' or 'YY'
  # if more types needed use ';' as separator.

end
EXAMPLE

        when 'behaviour_requires'
<<-EXAMPLE
# == requires
# *
module MyBehaviour

  # when no plugins required (TDriver internal/generic SUT behaviour)

end

or

# == requires
# testability-driver-my-plugin
module MyBehaviour

  # when plugin 'testability-driver-my-plugin' is required 

end
EXAMPLE


      else

        'Unknown help topic "%s"' % topic

      end

    end

    def self.for( options )

      new( options )

    end

    def load_templates

      Dir.glob( File.join( File.dirname( File.expand_path( __FILE__ ) ), '..', 'templates', '*.template' ) ).each{ | file |

        name = File.basename( file ).gsub( '.template', '' )

        @templates[ name ] = open( file, 'r' ).read

      }

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

      @processing = "method"

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

        end


      }

      result

    end


    def process_method( method )

      results = []

      method_header = nil

      if ( method.visibility == :public && @module_path.first =~ /MobyBehaviour/ )

        @current_method = method

 #       p method.methods.sort

        #p method.name

        #p method.section

        #p method.param_seq unless method.class == RDoc::Attr

#exit

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

        method_name = method.name

        if method.kind_of?( RDoc::Attr )

          case method.rw

            when "R"
              type = "reader"
            when "W"
              type = "writer"
              method_name << "="
            when "RW"
              type = "accessor"
              method_name << ";#{ method_name }="

          else

            raise_error( "Unknown attribute format for '#{ method.name }' ($MODULE). Expected 'R' (attr_reader), 'W' (attr_writer) or 'RW' (attr_accessor), got: '#{ method.rw }'" )

          end

          method_header.merge!( :__type => type )

        else

          method_header.merge!( :__type => "method" )

        end

        # do something
        [ method_name, method_header ]

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

      @processing = :attributes

      results = []

      attributes.each{ | attribute | 

        #p attribute.comment

        results << process_method( attribute )

        # TODO: tapa miten saadaan attribuuttien getteri ja setteri dokumentoitua implemenaatioon

      }

      Hash[ results ]

    end

    def process_comment( comment )

      header = {}

      current_section = nil

      return header if comment.nil? || comment.empty?

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

    def raise_error( text, topic = nil )

      type = ( @processing == "method" ) ? "method" : "attribute"

      text.gsub!( '$TYPE', type )

      text.gsub!( '$MODULE', @current_module.full_name )

      text = "=========================================================================================================\n" <<
        "File: #{ @module_in_files.join(", ") }\n" << text << "\n\nExample:\n\n"

      text << help( topic ) unless topic.nil?

      warn( text << "\n" )

    end

    def generate_return_values_element( header, feature )

      return "" if ( [ 'writer' ].include?( feature.last[ :__type ] ) )

      return if feature.last[ :returns ].nil? || feature.last[ :returns ].empty?

      if feature.last[ :returns ].nil?

        raise_error("Error: $TYPE '#{ feature.first }' ($MODULE) doesn't have return value type(s) defined", 'returns' )

      end

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

      apply_macros!( @templates["behaviour.xml.method.returns"].clone, {

          "METHOD_RETURNS" => returns

        }
      )
      
    end

    def generate_exceptions_element( header, feature )

      return "" if ( feature.last[:__type] != 'method' )

      if feature.last[ :exceptions ].nil?

        raise_error("Error: $TYPE '#{ feature.first }' ($MODULE) doesn't have exceptions(s) defined", 'exceptions' )

      end

      return "" if feature.last[ :exceptions ].nil? || feature.last[ :exceptions ].empty?

      # generate exceptions template
      exceptions = feature.last[ :exceptions ].collect{ | exceptions |
      
        exceptions.collect{ | exception |
        
           # apply types to exception template
           apply_macros!( @templates["behaviour.xml.exception"].clone, {
              "EXCEPTION_NAME" => exception.first,
              "EXCEPTION_DESCRIPTION" => exception.last["description"]
            }
           )
          
        }.join
     
      }.join

      apply_macros!( @templates["behaviour.xml.method.exceptions"].clone, {

          "METHOD_EXCEPTIONS" => exceptions

        }
      )

    end

    def generate_arguments_element( header, feature )

      return "" if ( feature.last[:__type] == 'reader' )

      #return "" if ( @processing == :attributes && feature.last[:__type] == 'R' )

      if feature.last[ :arguments ].nil?

        note = ". Note that also attribute writer requires input value defined as argument." if [ 'writer', 'accessor' ].include?( @processing )

        raise_error("Error: $TYPE '#{ feature.first }' ($MODULE) doesn't have arguments(s) defined#{ note }", [ 'writer', 'accessor' ].include?( @processing ) ? 'attr_argument' : 'arguments' )

      end

      # generate arguments xml
      arguments = ( feature.last[:arguments] || {} ).collect{ | arg |
        
        # generate argument types template
        arg.collect{ | argument |

         default_value_set = false 
         default_value = nil
                    
         types_xml = argument.last.collect{ | type |

           unless type.last["default"].nil?

             # show warning if default value for optional argument is already set
             raise_error( "Error: Default value for optional argument '%s' ($MODULE) is already set! ('%s' --> '%s')" % [ argument.first, default_value, type.last["default"] ] ) if default_value_set == true

             default_value = type.last["default"]
             default_value_set = true

           end

           if type.last["description"].nil?


            raise_error("Warning: Argument description for '%s' ($MODULE) is empty." % [ argument.first ], 'argument_description' )

           end

           if type.last["example"].nil?

            raise_error("Warning: Argument '%s' ($MODULE) example is empty." % [ argument.first ])

           end

           apply_macros!( @templates["behaviour.xml.argument_type"].clone, {
            
              "ARGUMENT_TYPE" => type.first,
              "ARGUMENT_DESCRIPTION" => type.last["description"],
              "ARGUMENT_EXAMPLE" => type.last["example"],
           
            }
           )
         
         }.join
         
        if default_value_set

          default_value = apply_macros!( @templates["behaviour.xml.argument.default"].clone, { 
            "ARGUMENT_DEFAULT_VALUE" => default_value || ""
            }
          )

        else

          default_value = ""

        end


         # apply types to arguments template
         apply_macros!( @templates["behaviour.xml.argument"].clone, {
            "ARGUMENT_NAME" => argument.first,
            "ARGUMENT_TYPES" => types_xml,
            "ARGUMENT_DEFAULT_VALUE" => default_value,
            "ARGUMENT_OPTIONAL" => default_value_set.to_s
          }
         )
        
        }.join
      
      }.join

      apply_macros!( @templates["behaviour.xml.method.arguments"].clone, {

          "METHOD_ARGUMENTS" => arguments

        }
      )


    end

    def generate_methods_element( header, features )

      # collect method and attribute templates
      methods = features.collect{ | feature_set |
      
        feature_set.collect{ | feature |
                  
          @processing = feature.last[:__type]
            
          # TODO: tarkista lähdekoodista että onko argument optional vai ei
          # TODO: tarkista että onko kaikki argumentit dokumentoitu
          
          arguments = generate_arguments_element( header, feature )

          returns = generate_return_values_element( header, feature )

          exceptions = generate_exceptions_element( header, feature )
                    
          if feature.last[:description].nil?

           raise_error("Warning: $TYPE description for '#{ feature.first }' ($MODULE) is empty.", 'description')

          end
                              
          # generate method template            
          apply_macros!( @templates["behaviour.xml.method"].clone, { 
            "METHOD_NAME" => feature.first,
            "METHOD_TYPE" => feature.last[:__type] || "unknown",
            "METHOD_DESCRIPTION" => feature.last[:description],
            "METHOD_ARGUMENTS" => arguments,
            "METHOD_RETURNS" => returns,
            "METHOD_EXCEPTIONS" => exceptions,
            "METHOD_INFO" => feature.last[:info]
           } 
          )

        }.join
      
      }.join


    end

    def generate_behaviour_element( header, methods )

      # verify that behaviour description is defined
      unless header.has_key?(:description)

         raise_error("Warning: Behaviour description for $MODULE is empty.", 'behaviour_description' )

      end

      # verify that behaviour name is defined
      unless header.has_key?(:behaviour)

         raise_error("Warning: Behaviour name for $MODULE is not defined.", 'behaviour_name' )

      end

      # verify that behaviour object type(s) is defined
      unless header.has_key?(:objects)

         raise_error("Warning: Behaviour object type(s) for $MODULE is not defined.", 'behaviour_object_types' )

      end

      # verify that behaviour sut type(s) is defined
      unless header.has_key?(:sut_type)

         raise_error("Warning: Behaviour SUT type for $MODULE is not defined.", 'behaviour_sut_type' )

      end

      # verify that behaviour input type(s) is defined
      unless header.has_key?(:input_type)

         raise_error("Warning: Behaviour input type for $MODULE is not defined.", 'behaviour_input_type' )

      end

      # verify that behaviour sut version(s) is defined
      unless header.has_key?(:sut_version)

         raise_error("Warning: Behaviour SUT version for $MODULE is not defined.", 'behaviour_version' )

      end

      # verify that behaviour sut version(s) is defined
      unless header.has_key?(:requires)

         raise_error("Warning: Required plugin name is not defined for $MODULE.", 'behaviour_requires' )

      end

      # apply header
      text = apply_macros!( @templates["behaviour.xml"].clone, { 
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
    
      # remove extra linefeeds
      text.gsub!( /^[\n]+/, "\n" )

      text.gsub!( /^(\s)*$/, "" )

      text

    end

    def generate_behaviour( header, *features )

      methods = generate_methods_element( header, features )

      generate_behaviour_element( header, methods )

    end

    def process_module( _module )

      @already_processed_files << _module.full_name

      module_header = process_comment( _module.comment )

      # store information where module is stored
      @module_in_files = _module.in_files.collect{ | file | file.file_absolute_name }

      #unless module_header.empty?

        @current_module = _module

        # process methods
        methods = process_methods( _module.method_list )

        # process attributes
        attributes = process_attributes( _module.attributes )

        print "  ... %s" % module_header[:behaviour]

        xml = generate_behaviour( module_header, methods, attributes ) 

        xml_file_name = '%s.%s' % [ module_header[:behaviour], 'xml' ]

        begin

          if xml_file_name != '.xml' 

            open( xml_file_name, 'w'){ | file | file << xml }

            puts ".xml"

          else

            warn("Skip: output XML not saved due to module #{ @module_path.join("::") } does not have proper behaviour name/description in #{ @module_in_files.join(", ") }")

          end

        rescue Exception => exception

          warn("Warning: Error writing file %s (%s: %s)" % [ xml_file_name, exception.class, exception.message ] )

        end

      #end

      # process if any child modules 
      process_modules( _module.modules ) unless _module.modules.empty?

    end

  end

end

